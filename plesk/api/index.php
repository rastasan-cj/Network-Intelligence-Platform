<?php
declare(strict_types=1);

// ─── Bootstrap ────────────────────────────────────────────────────────────────
require_once __DIR__ . '/config.php';

// ─── Autoload src classes ──────────────────────────────────────────────────────
$srcDir = __DIR__ . '/src';
foreach (glob($srcDir . '/*.php') as $f)            require_once $f;
foreach (glob($srcDir . '/controllers/*.php') as $f) require_once $f;

// ─── CORS ─────────────────────────────────────────────────────────────────────
$origin  = $_SERVER['HTTP_ORIGIN'] ?? '*';
$allowed = array_filter(array_map('trim', explode(',', $_ENV['CORS_ORIGINS'] ?? '*')));

if (in_array('*', $allowed) || in_array($origin, $allowed)) {
    header("Access-Control-Allow-Origin: $origin");
} else {
    header('Access-Control-Allow-Origin: ' . ($_ENV['FRONTEND_URL'] ?? '*'));
}
header('Access-Control-Allow-Credentials: true');
header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// ─── Router ───────────────────────────────────────────────────────────────────
$method = strtoupper($_SERVER['REQUEST_METHOD']);

// Strip /api prefix and parse path segments
$uri   = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$uri   = preg_replace('#^/api#', '', $uri);
$uri   = rtrim($uri, '/') ?: '/';
$parts = explode('/', ltrim($uri, '/'));

$seg0 = $parts[0] ?? '';
$seg1 = $parts[1] ?? '';
$seg2 = $parts[2] ?? '';

$id = is_numeric($seg1) ? (int)$seg1 : null;

// ─── Route Definitions ────────────────────────────────────────────────────────
try {

    // ── HEALTH ────────────────────────────────────────────────────────────────
    if ($seg0 === 'health' || $seg0 === '') {
        Response::json([
            'status'  => 'ok',
            'version' => $_ENV['APP_VERSION'] ?? '0.1.0',
            'php'     => PHP_VERSION,
            'time'    => date('c'),
        ]);

    // ── AUTH ──────────────────────────────────────────────────────────────────
    } elseif ($seg0 === 'auth') {

        match (true) {
            $seg1 === 'login'         && $method === 'POST' => AuthController::login(),
            $seg1 === 'logout'        && $method === 'POST' => AuthController::logout(),
            $seg1 === 'refresh-token' && $method === 'POST' => AuthController::refreshToken(),
            $seg1 === 'me'            && $method === 'GET'  => AuthController::me(),
            default => Response::notFound("Auth endpoint /$seg1 not found"),
        };

    // ── AUDIT LOG ─────────────────────────────────────────────────────────────
    } elseif ($seg0 === 'audit-logs') {
        Auth::requirePermission('audit.view');
        $page    = max(1, (int) ($_GET['page']     ?? 1));
        $perPage = min(200, max(10, (int) ($_GET['per_page'] ?? 50)));
        Response::success(AuditLog::list($page, $perPage));

    // ── CATCH-ALL ─────────────────────────────────────────────────────────────
    } else {
        Response::notFound("Endpoint /$seg0 not found");
    }

} catch (Throwable $e) {
    $debug = ($_ENV['APP_DEBUG'] ?? 'false') === 'true';
    Response::json(
        $debug
            ? ['detail' => $e->getMessage(), 'file' => $e->getFile(), 'line' => $e->getLine()]
            : ['detail' => 'Internal server error'],
        500
    );
}
