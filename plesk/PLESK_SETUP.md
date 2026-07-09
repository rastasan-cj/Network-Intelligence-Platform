# دليل نشر 249-NIP على Plesk

## المتطلبات
- Plesk Obsidian أو أحدث
- PHP 8.1+
- MySQL 8.0+ أو MariaDB 10.6+

---

## خطوات النشر

### 1. رفع الملفات

ارفع `plesk_deploy.zip` إلى جذر النطاق في Plesk وفكّ ضغطه:

```bash
unzip plesk_deploy.zip -d /var/www/vhosts/yourdomain.com/httpdocs/
```

الهيكل المتوقع بعد الاستخراج:
```
httpdocs/
├── .htaccess          ← Apache routing (SPA + API)
├── index.html         ← React frontend (مبني)
├── version.json
├── assets/            ← JS + CSS مبني
│   ├── index-[hash].js
│   └── index-[hash].css
└── api/               ← PHP backend
    ├── .htaccess
    ├── config.php     ← ← ← عدّل هذا الملف
    ├── schema.sql
    ├── create_admin.php
    └── src/
```

### 2. إنشاء قاعدة البيانات (Plesk)

1. افتح **Plesk → Databases → Add Database**
2. اسم القاعدة: `nip_db` (أو أي اسم)
3. أنشئ مستخدم قاعدة بيانات وكلمة مرور
4. استورد قاعدة البيانات عبر phpMyAdmin:
   - **Import → اختر `api/full_setup.sql`** (ملف واحد يجمع الجداول + البيانات الأولية)

### 3. ضبط config.php

عدّل الملف `api/config.php` بالقيم الحقيقية:

```php
$_ENV['DB_HOST'] = 'localhost';
$_ENV['DB_NAME'] = 'nip_db';           // ← اسم قاعدة البيانات
$_ENV['DB_USER'] = 'your_db_user';     // ← مستخدم DB
$_ENV['DB_PASS'] = 'your_db_password'; // ← كلمة مرور DB

// أنشئ سر قوي: openssl rand -hex 64
$_ENV['JWT_SECRET'] = 'CHANGE_ME_64_CHAR_RANDOM';

$_ENV['CORS_ORIGINS'] = 'https://yourdomain.com';
$_ENV['FRONTEND_URL'] = 'https://yourdomain.com';
```

### 4. إنشاء حساب المدير

```bash
cd /var/www/vhosts/yourdomain.com/httpdocs/api
php create_admin.php admin admin@yourdomain.com "MyStr0ng@Pass!"
```

**احذف السكريبت فوراً بعد الانتهاء:**
```bash
rm create_admin.php
```

### 5. إعدادات PHP في Plesk

في **Plesk → PHP Settings** للنطاق:

| الإعداد | القيمة |
|---------|--------|
| PHP Version | 8.1 أو أحدث |
| upload_max_filesize | 10M |
| post_max_size | 12M |
| max_execution_time | 60 |
| memory_limit | 128M |

---

## التحقق من النشر

افتح المتصفح:
```
https://yourdomain.com/api/health
```

المتوقع:
```json
{"status": "ok", "version": "0.1.0", "php": "8.x.x", "time": "..."}
```

---

## استكشاف الأخطاء

| المشكلة | الحل |
|---------|------|
| خطأ 500 عند `/api/health` | تحقق من `api/config.php` وبيانات DB |
| خطأ 403 على `config.php` | هذا صحيح — الملف محمي بـ .htaccess |
| صفحة بيضاء للـ Frontend | تأكد أن Document Root يشير إلى `httpdocs/` |
| CORS error في المتصفح | عدّل `CORS_ORIGINS` في `config.php` ليتطابق مع نطاقك |
