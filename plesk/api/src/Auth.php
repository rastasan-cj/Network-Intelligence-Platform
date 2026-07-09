<?php
declare(strict_types=1);

class Auth
{
    private static ?array $currentUser = null;

    /**
     * Extract bearer token from Authorization header.
     */
    public static function getBearerToken(): ?string
    {
        $header = $_SERVER['HTTP_AUTHORIZATION']
            ?? apache_request_headers()['Authorization']
            ?? '';

        if (preg_match('/^Bearer\s+(.+)$/i', $header, $m)) {
            return trim($m[1]);
        }
        return null;
    }

    /**
     * Verify token and return payload, or null on failure.
     */
    public static function verify(): ?array
    {
        $token = self::getBearerToken();
        if ($token === null) {
            return null;
        }
        return JWT::decode($token, $_ENV['JWT_SECRET'] ?? '');
    }

    /**
     * Require valid token; abort with 401 if missing or invalid.
     * Returns the payload.
     */
    public static function require(): array
    {
        $payload = self::verify();
        if ($payload === null) {
            Response::unauthorized('يجب تسجيل الدخول أولاً');
        }
        self::$currentUser = $payload;
        return $payload;
    }

    /**
     * Require a specific role; abort with 403 if not allowed.
     */
    public static function requireRole(string ...$roles): array
    {
        $payload = self::require();
        if (!in_array($payload['role'] ?? '', $roles, true)
            && !($payload['is_super_admin'] ?? false)) {
            Response::forbidden('ليس لديك صلاحية للوصول إلى هذا المورد');
        }
        return $payload;
    }

    /**
     * Require a specific permission; abort with 403 if not allowed.
     */
    public static function requirePermission(string $permission): array
    {
        $payload = self::require();
        $permissions = $payload['permissions'] ?? [];
        if (!in_array($permission, $permissions, true)
            && !($payload['is_super_admin'] ?? false)) {
            Response::forbidden('ليس لديك صلاحية: ' . $permission);
        }
        return $payload;
    }

    /**
     * Return current authenticated user data from payload.
     */
    public static function user(): ?array
    {
        return self::$currentUser;
    }
}
