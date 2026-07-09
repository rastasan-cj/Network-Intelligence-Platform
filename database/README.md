# Database Setup — 249-NIP

## Requirements
- MySQL 8.0+ or MariaDB 10.6+
- Character set: `utf8mb4`
- Collation: `utf8mb4_unicode_ci`

## Steps

### 1. Create the database
```sql
CREATE DATABASE nip_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
```

### 2. Run the schema
```bash
mysql -u root -p nip_db < database/schema.sql
```

### 3. Run the seed data
```bash
mysql -u root -p nip_db < database/seeds.sql
```

## Default Admin Credentials
| Field    | Value              |
|----------|--------------------|
| Username | `admin`            |
| Password | `Admin@249NIP`     |
| Email    | `admin@249nip.local` |

> ⚠️ Change the password immediately after first login.

## Tables

| Table                  | Description                          |
|------------------------|--------------------------------------|
| `organizations`        | المؤسسات                             |
| `branches`             | الفروع                               |
| `departments`          | الأقسام                              |
| `locations`            | المواقع داخل الفرع                   |
| `roles`                | الأدوار (Super Admin, Admin, …)      |
| `permissions`          | الصلاحيات المتاحة                   |
| `role_permissions`     | ربط الصلاحيات بالأدوار              |
| `users`                | المستخدمون (مع Soft Delete)          |
| `user_roles`           | ربط المستخدمين بالأدوار             |
| `sessions`             | جلسات المستخدمين (server-side)       |
| `refresh_tokens`       | JWT Refresh Tokens                   |
| `password_reset_tokens`| رموز إعادة تعيين كلمة المرور        |
| `login_attempts`       | حماية Brute Force                    |
| `settings`             | إعدادات النظام (Key-Value)           |
| `audit_logs`           | سجل التدقيق                          |
