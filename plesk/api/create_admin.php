<?php
/**
 * 249-NIP — Bootstrap Super Admin
 * ─────────────────────────────────────────────────────────────────────────────
 * Run ONCE from the server CLI after importing schema.sql:
 *
 *   php create_admin.php <username> <email> <password>
 *
 * Example:
 *   php create_admin.php admin admin@yourdomain.com "MyStr0ng@Pass!"
 *
 * ⚠️  DELETE this file immediately after use!
 *     rm create_admin.php
 * ─────────────────────────────────────────────────────────────────────────────
 */

declare(strict_types=1);

// Only allow CLI execution
if (PHP_SAPI !== 'cli') {
    http_response_code(403);
    echo json_encode(['error' => 'This script must be run from the command line.']);
    exit(1);
}

// Load config
require_once __DIR__ . '/config.php';

$username = $argv[1] ?? '';
$email    = $argv[2] ?? '';
$password = $argv[3] ?? '';

if ($username === '' || $email === '' || $password === '') {
    fwrite(STDERR, "Usage: php create_admin.php <username> <email> <password>\n");
    exit(1);
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    fwrite(STDERR, "Error: Invalid email address.\n");
    exit(1);
}

if (strlen($password) < 8) {
    fwrite(STDERR, "Error: Password must be at least 8 characters.\n");
    exit(1);
}

try {
    $dsn = sprintf(
        'mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
        $_ENV['DB_HOST'] ?? 'localhost',
        $_ENV['DB_PORT'] ?? '3306',
        $_ENV['DB_NAME'] ?? 'nip_db'
    );
    $pdo = new PDO($dsn, $_ENV['DB_USER'] ?? 'root', $_ENV['DB_PASS'] ?? '', [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
} catch (PDOException $e) {
    fwrite(STDERR, "Database connection failed: " . $e->getMessage() . "\n");
    exit(1);
}

// Check if username or email already exists
$check = $pdo->prepare('SELECT id FROM users WHERE username = :u OR email = :e');
$check->execute([':u' => $username, ':e' => $email]);
if ($check->fetch()) {
    fwrite(STDERR, "Error: Username or email already exists.\n");
    exit(1);
}

$cost = max(10, min(14, (int) ($_ENV['BCRYPT_COST'] ?? 12)));
$hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => $cost]);
$uuid = sprintf(
    '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
    mt_rand(0, 0xffff), mt_rand(0, 0xffff),
    mt_rand(0, 0xffff),
    mt_rand(0, 0x0fff) | 0x4000,
    mt_rand(0, 0x3fff) | 0x8000,
    mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
);

$pdo->prepare(
    'INSERT INTO users (uuid, username, email, password_hash, full_name, is_active, is_super_admin, branch_id)
     VALUES (:uuid, :username, :email, :hash, :name, 1, 1, 1)'
)->execute([
    ':uuid'     => $uuid,
    ':username' => $username,
    ':email'    => $email,
    ':hash'     => $hash,
    ':name'     => ucfirst($username),
]);

$userId = (int) $pdo->lastInsertId();

// Assign super_admin role (id = 1, inserted by seeds.sql)
$pdo->prepare('INSERT IGNORE INTO user_roles (user_id, role_id) VALUES (:uid, 1)')
    ->execute([':uid' => $userId]);

echo "✅ Admin created successfully!\n";
echo "   Username : $username\n";
echo "   Email    : $email\n";
echo "   User ID  : $userId\n";
echo "\n⚠️  DELETE this file now:\n";
echo "   rm " . __FILE__ . "\n";
