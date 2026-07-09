<?php
declare(strict_types=1);

class AuthController
{
    // ── POST /api/auth/login ──────────────────────────────────────────────────
    public static function login(): void
    {
        $body     = json_decode(file_get_contents('php://input'), true) ?? [];
        $login    = trim($body['username'] ?? $body['email'] ?? '');
        $password = $body['password'] ?? '';

        if ($login === '' || $password === '') {
            Response::error('اسم المستخدم وكلمة المرور مطلوبان', 422);
        }

        $db = Database::getInstance();
        $ip = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '';

        // ── Rate limiting ──────────────────────────────────────────────────────
        $maxAttempts     = (int) ($_ENV['MAX_LOGIN_ATTEMPTS'] ?? 5);
        $lockoutDuration = (int) ($_ENV['LOCKOUT_DURATION']   ?? 900);

        $attemptsStmt = $db->prepare(
            'SELECT COUNT(*) FROM login_attempts
             WHERE identifier = :id AND ip_address = :ip
               AND success = 0
               AND created_at > DATE_SUB(NOW(), INTERVAL :dur SECOND)'
        );
        $attemptsStmt->execute([':id' => $login, ':ip' => $ip, ':dur' => $lockoutDuration]);
        $recentFails = (int) $attemptsStmt->fetchColumn();

        if ($recentFails >= $maxAttempts) {
            Response::error('تم تجاوز عدد المحاولات. حاول مجدداً بعد قليل.', 429);
        }

        // ── Fetch user ─────────────────────────────────────────────────────────
        $stmt = $db->prepare(
            'SELECT u.*,
                    GROUP_CONCAT(DISTINCT r.name ORDER BY r.name SEPARATOR ",")  AS role_names,
                    GROUP_CONCAT(DISTINCT p.name ORDER BY p.name SEPARATOR ",")  AS permission_names
             FROM users u
             LEFT JOIN user_roles      ur ON ur.user_id = u.id
             LEFT JOIN roles            r ON r.id = ur.role_id
             LEFT JOIN role_permissions rp ON rp.role_id = r.id
             LEFT JOIN permissions      p ON p.id = rp.permission_id
             WHERE (u.username = :login OR u.email = :login)
               AND u.deleted_at IS NULL
             GROUP BY u.id'
        );
        $stmt->execute([':login' => $login]);
        $user = $stmt->fetch();

        // Record attempt (success determined later)
        $logStmt = $db->prepare(
            'INSERT INTO login_attempts (identifier, ip_address, success) VALUES (:id, :ip, :ok)'
        );

        if (!$user || !password_verify($password, $user['password_hash'])) {
            $logStmt->execute([':id' => $login, ':ip' => $ip, ':ok' => 0]);
            Response::error('اسم المستخدم أو كلمة المرور غير صحيحة', 401);
        }

        if (!(bool) $user['is_active']) {
            Response::error('هذا الحساب معطّل. تواصل مع المسؤول.', 403);
        }

        // ── Issue tokens ───────────────────────────────────────────────────────
        $secret     = $_ENV['JWT_SECRET']      ?? '';
        $accessTtl  = (int) ($_ENV['JWT_ACCESS_TTL']  ?? 900);
        $refreshTtl = (int) ($_ENV['JWT_REFRESH_TTL'] ?? 604800);

        $roles       = array_filter(explode(',', $user['role_names']       ?? ''));
        $permissions = array_filter(explode(',', $user['permission_names'] ?? ''));

        $payload = [
            'sub'            => $user['id'],
            'uuid'           => $user['uuid'],
            'username'       => $user['username'],
            'full_name'      => $user['full_name'],
            'is_super_admin' => (bool) $user['is_super_admin'],
            'roles'          => array_values($roles),
            'permissions'    => array_values($permissions),
        ];

        $accessToken  = JWT::encode($payload, $secret, $accessTtl);
        $refreshToken = JWT::encode(['sub' => $user['id'], 'type' => 'refresh'], $secret, $refreshTtl);
        $refreshHash  = hash('sha256', $refreshToken);

        // Store refresh token
        $db->prepare(
            'INSERT INTO refresh_tokens (user_id, token_hash, expires_at, ip_address, user_agent)
             VALUES (:uid, :hash, DATE_ADD(NOW(), INTERVAL :ttl SECOND), :ip, :ua)'
        )->execute([
            ':uid'  => $user['id'],
            ':hash' => $refreshHash,
            ':ttl'  => $refreshTtl,
            ':ip'   => $ip,
            ':ua'   => $_SERVER['HTTP_USER_AGENT'] ?? null,
        ]);

        // Update last login
        $db->prepare('UPDATE users SET last_login_at = NOW(), last_login_ip = :ip WHERE id = :id')
           ->execute([':ip' => $ip, ':id' => $user['id']]);

        $logStmt->execute([':id' => $login, ':ip' => $ip, ':ok' => 1]);
        AuditLog::record($user['id'], 'login', 'auth');

        Response::success([
            'access_token'  => $accessToken,
            'refresh_token' => $refreshToken,
            'expires_in'    => $accessTtl,
            'user'          => $payload,
        ], 'تم تسجيل الدخول بنجاح');
    }

    // ── POST /api/auth/logout ─────────────────────────────────────────────────
    public static function logout(): void
    {
        $payload = Auth::verify();

        if ($payload !== null) {
            $body = json_decode(file_get_contents('php://input'), true) ?? [];
            if (!empty($body['refresh_token'])) {
                $hash = hash('sha256', $body['refresh_token']);
                Database::getInstance()
                    ->prepare('UPDATE refresh_tokens SET revoked_at = NOW() WHERE token_hash = :h')
                    ->execute([':h' => $hash]);
            }
            AuditLog::record($payload['sub'], 'logout', 'auth');
        }

        Response::success(null, 'تم تسجيل الخروج بنجاح');
    }

    // ── POST /api/auth/refresh-token ──────────────────────────────────────────
    public static function refreshToken(): void
    {
        $body  = json_decode(file_get_contents('php://input'), true) ?? [];
        $token = $body['refresh_token'] ?? '';

        if ($token === '') {
            Response::error('Refresh token مطلوب', 422);
        }

        $secret = $_ENV['JWT_SECRET'] ?? '';
        $claims = JWT::decode($token, $secret);

        if ($claims === null || ($claims['type'] ?? '') !== 'refresh') {
            Response::error('Refresh token غير صالح أو منتهي الصلاحية', 401);
        }

        $hash = hash('sha256', $token);
        $db   = Database::getInstance();

        $rt = $db->prepare(
            'SELECT * FROM refresh_tokens
             WHERE token_hash = :h AND revoked_at IS NULL AND expires_at > NOW()'
        );
        $rt->execute([':h' => $hash]);
        $record = $rt->fetch();

        if (!$record) {
            Response::error('Refresh token منتهي أو ملغى', 401);
        }

        // Fetch user + roles + permissions
        $stmt = $db->prepare(
            'SELECT u.*,
                    GROUP_CONCAT(DISTINCT r.name ORDER BY r.name SEPARATOR ",")  AS role_names,
                    GROUP_CONCAT(DISTINCT p.name ORDER BY p.name SEPARATOR ",")  AS permission_names
             FROM users u
             LEFT JOIN user_roles      ur ON ur.user_id = u.id
             LEFT JOIN roles            r ON r.id = ur.role_id
             LEFT JOIN role_permissions rp ON rp.role_id = r.id
             LEFT JOIN permissions      p ON p.id = rp.permission_id
             WHERE u.id = :uid AND u.deleted_at IS NULL AND u.is_active = 1
             GROUP BY u.id'
        );
        $stmt->execute([':uid' => $claims['sub']]);
        $user = $stmt->fetch();

        if (!$user) {
            Response::error('المستخدم غير موجود أو معطّل', 401);
        }

        // Revoke old token, issue new pair
        $db->prepare('UPDATE refresh_tokens SET revoked_at = NOW() WHERE token_hash = :h')
           ->execute([':h' => $hash]);

        $accessTtl  = (int) ($_ENV['JWT_ACCESS_TTL']  ?? 900);
        $refreshTtl = (int) ($_ENV['JWT_REFRESH_TTL'] ?? 604800);

        $roles       = array_filter(explode(',', $user['role_names']       ?? ''));
        $permissions = array_filter(explode(',', $user['permission_names'] ?? ''));

        $payload = [
            'sub'            => $user['id'],
            'uuid'           => $user['uuid'],
            'username'       => $user['username'],
            'full_name'      => $user['full_name'],
            'is_super_admin' => (bool) $user['is_super_admin'],
            'roles'          => array_values($roles),
            'permissions'    => array_values($permissions),
        ];

        $newAccess  = JWT::encode($payload, $secret, $accessTtl);
        $newRefresh = JWT::encode(['sub' => $user['id'], 'type' => 'refresh'], $secret, $refreshTtl);
        $newHash    = hash('sha256', $newRefresh);

        $ip = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '';
        $db->prepare(
            'INSERT INTO refresh_tokens (user_id, token_hash, expires_at, ip_address, user_agent)
             VALUES (:uid, :hash, DATE_ADD(NOW(), INTERVAL :ttl SECOND), :ip, :ua)'
        )->execute([
            ':uid'  => $user['id'],
            ':hash' => $newHash,
            ':ttl'  => $refreshTtl,
            ':ip'   => $ip,
            ':ua'   => $_SERVER['HTTP_USER_AGENT'] ?? null,
        ]);

        Response::success([
            'access_token'  => $newAccess,
            'refresh_token' => $newRefresh,
            'expires_in'    => $accessTtl,
        ], 'تم تجديد التوكن بنجاح');
    }

    // ── GET /api/auth/me ──────────────────────────────────────────────────────
    public static function me(): void
    {
        $payload = Auth::require();

        $db   = Database::getInstance();
        $stmt = $db->prepare(
            'SELECT u.id, u.uuid, u.username, u.email, u.full_name, u.phone,
                    u.avatar, u.is_active, u.is_super_admin,
                    u.last_login_at, u.last_login_ip, u.created_at,
                    GROUP_CONCAT(DISTINCT r.name ORDER BY r.name SEPARATOR ",")        AS role_names,
                    GROUP_CONCAT(DISTINCT r.display_name ORDER BY r.name SEPARATOR ",") AS role_labels,
                    GROUP_CONCAT(DISTINCT p.name ORDER BY p.name SEPARATOR ",")        AS permission_names
             FROM users u
             LEFT JOIN user_roles      ur ON ur.user_id = u.id
             LEFT JOIN roles            r ON r.id = ur.role_id
             LEFT JOIN role_permissions rp ON rp.role_id = r.id
             LEFT JOIN permissions      p ON p.id = rp.permission_id
             WHERE u.id = :uid AND u.deleted_at IS NULL
             GROUP BY u.id'
        );
        $stmt->execute([':uid' => $payload['sub']]);
        $user = $stmt->fetch();

        if (!$user) {
            Response::notFound('المستخدم غير موجود');
        }

        Response::success([
            'id'             => $user['id'],
            'uuid'           => $user['uuid'],
            'username'       => $user['username'],
            'email'          => $user['email'],
            'full_name'      => $user['full_name'],
            'phone'          => $user['phone'],
            'avatar'         => $user['avatar'],
            'is_active'      => (bool) $user['is_active'],
            'is_super_admin' => (bool) $user['is_super_admin'],
            'roles'          => array_values(array_filter(explode(',', $user['role_names'] ?? ''))),
            'role_labels'    => array_values(array_filter(explode(',', $user['role_labels'] ?? ''))),
            'permissions'    => array_values(array_filter(explode(',', $user['permission_names'] ?? ''))),
            'last_login_at'  => $user['last_login_at'],
            'last_login_ip'  => $user['last_login_ip'],
            'created_at'     => $user['created_at'],
        ]);
    }
}
