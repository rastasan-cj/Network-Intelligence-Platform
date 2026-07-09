<?php

declare(strict_types=1);

define('ROOT_PATH', dirname(__DIR__));
define('SRC_PATH', ROOT_PATH . '/src');

require ROOT_PATH . '/vendor/autoload.php';

// Load environment variables
$dotenv = Dotenv\Dotenv::createImmutable(ROOT_PATH);
$dotenv->safeLoad();

// CORS Headers
$allowedOrigins = explode(',', $_ENV['CORS_ALLOWED_ORIGINS'] ?? 'http://localhost:5000');
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';

if (in_array($origin, $allowedOrigins) || ($_ENV['APP_ENV'] ?? 'development') === 'development') {
    header('Access-Control-Allow-Origin: ' . ($origin ?: '*'));
}
header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json; charset=utf-8');

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// Bootstrap router
$router = new \Bramus\Router\Router();

// Health check
$router->get('/health', function () {
    echo json_encode([
        'status'  => 'ok',
        'version' => '0.1.0',
        'php'     => PHP_VERSION,
        'time'    => date('c'),
    ]);
});

// API v1 routes
$router->mount('/api', function () use ($router) {

    // Auth routes
    $router->mount('/auth', function () use ($router) {
        $router->post('/login',         '\NIP\Controllers\AuthController@login');
        $router->post('/logout',        '\NIP\Controllers\AuthController@logout');
        $router->post('/refresh-token', '\NIP\Controllers\AuthController@refreshToken');
        $router->get('/me',             '\NIP\Controllers\AuthController@me');
    });

});

// 404 fallback
$router->set404(function () {
    http_response_code(404);
    echo json_encode(['error' => 'Route not found']);
});

$router->run();
