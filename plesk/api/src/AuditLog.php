<?php
declare(strict_types=1);

class AuditLog
{
    /**
     * Record an audit event.
     */
    public static function record(
        ?int $userId,
        string $action,
        string $module,
        string $targetType = null,
        int $targetId = null,
        array $oldValues = null,
        array $newValues = null
    ): void {
        try {
            $db = Database::getInstance();
            $stmt = $db->prepare(
                'INSERT INTO audit_logs
                    (user_id, action, module, target_type, target_id, old_values, new_values, ip_address, user_agent)
                 VALUES
                    (:user_id, :action, :module, :target_type, :target_id, :old_values, :new_values, :ip, :ua)'
            );
            $stmt->execute([
                ':user_id'     => $userId,
                ':action'      => $action,
                ':module'      => $module,
                ':target_type' => $targetType,
                ':target_id'   => $targetId,
                ':old_values'  => $oldValues  !== null ? json_encode($oldValues,  JSON_UNESCAPED_UNICODE) : null,
                ':new_values'  => $newValues  !== null ? json_encode($newValues,  JSON_UNESCAPED_UNICODE) : null,
                ':ip'          => self::clientIp(),
                ':ua'          => $_SERVER['HTTP_USER_AGENT'] ?? null,
            ]);
        } catch (Throwable) {
            // Never let logging failures break the request
        }
    }

    /**
     * List audit logs — returns paginated results.
     */
    public static function list(int $page = 1, int $perPage = 50): array
    {
        $db     = Database::getInstance();
        $offset = ($page - 1) * $perPage;

        $total = (int) $db->query('SELECT COUNT(*) FROM audit_logs')->fetchColumn();
        $rows  = $db->query(
            "SELECT al.*, u.username, u.full_name
             FROM audit_logs al
             LEFT JOIN users u ON al.user_id = u.id
             ORDER BY al.created_at DESC
             LIMIT $perPage OFFSET $offset"
        )->fetchAll();

        return [
            'data'        => $rows,
            'total'       => $total,
            'page'        => $page,
            'per_page'    => $perPage,
            'total_pages' => (int) ceil($total / $perPage),
        ];
    }

    private static function clientIp(): string
    {
        return $_SERVER['HTTP_X_FORWARDED_FOR']
            ?? $_SERVER['HTTP_X_REAL_IP']
            ?? $_SERVER['REMOTE_ADDR']
            ?? '';
    }
}
