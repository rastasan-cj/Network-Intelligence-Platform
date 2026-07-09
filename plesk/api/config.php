<?php
declare(strict_types=1);

// ─── Application ──────────────────────────────────────────────────────────────
$_ENV['APP_DEBUG'] = 'false';
$_ENV['APP_ENV']   = 'production';
$_ENV['APP_VERSION'] = '0.1.0';

// ─── JWT ──────────────────────────────────────────────────────────────────────
// Generate a strong secret: openssl rand -hex 64
$_ENV['JWT_SECRET']       = 'CHANGE_ME_USE_STRONG_RANDOM_SECRET_64_CHARS_MINIMUM';
$_ENV['JWT_ACCESS_TTL']   = '900';     // 15 minutes (seconds)
$_ENV['JWT_REFRESH_TTL']  = '604800';  // 7 days (seconds)

// ─── Database ─────────────────────────────────────────────────────────────────
$_ENV['DB_HOST'] = 'localhost';
$_ENV['DB_PORT'] = '3306';
$_ENV['DB_NAME'] = 'nip_db';
$_ENV['DB_USER'] = 'CHANGE_ME_DB_USER';
$_ENV['DB_PASS'] = 'CHANGE_ME_DB_PASSWORD';

// ─── CORS / Frontend URL ──────────────────────────────────────────────────────
$_ENV['CORS_ORIGINS']  = 'https://YOUR-DOMAIN.com';
$_ENV['FRONTEND_URL']  = 'https://YOUR-DOMAIN.com';

// ─── Security ─────────────────────────────────────────────────────────────────
$_ENV['BCRYPT_COST']        = '12';
$_ENV['MAX_LOGIN_ATTEMPTS'] = '5';
$_ENV['LOCKOUT_DURATION']   = '900';   // 15 minutes (seconds)

// ─── Uploads ──────────────────────────────────────────────────────────────────
$_ENV['UPLOAD_MAX_SIZE'] = '10485760'; // 10 MB
