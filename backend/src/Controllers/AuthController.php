<?php

declare(strict_types=1);

namespace NIP\Controllers;

use NIP\Helpers\Response;

class AuthController
{
    public function login(): void
    {
        $body = json_decode(file_get_contents('php://input'), true) ?? [];
        $username = trim($body['username'] ?? '');
        $password  = $body['password'] ?? '';

        if (empty($username) || empty($password)) {
            Response::error('اسم المستخدم وكلمة المرور مطلوبان', 422);
        }

        // TODO: Replace with real DB lookup in section 1.2
        Response::error('قاعدة البيانات لم تُعدّ بعد — سيُكتمل في المرحلة 1.2', 503);
    }

    public function logout(): void
    {
        Response::success(null, 'تم تسجيل الخروج بنجاح');
    }

    public function refreshToken(): void
    {
        Response::error('لم يُنفّذ بعد', 501);
    }

    public function me(): void
    {
        Response::error('لم يُنفّذ بعد', 501);
    }
}
