-- ============================================================
-- Network Intelligence Platform (249-NIP)
-- MySQL / MariaDB Schema — Version 1.0
-- Encoding: utf8mb4 | Collation: utf8mb4_unicode_ci
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- TABLE: organizations
-- ============================================================
CREATE TABLE IF NOT EXISTS `organizations` (
  `id`          INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  `name`        VARCHAR(150)     NOT NULL,
  `logo`        VARCHAR(500)     DEFAULT NULL,
  `description` TEXT             DEFAULT NULL,
  `website`     VARCHAR(255)     DEFAULT NULL,
  `phone`       VARCHAR(30)      DEFAULT NULL,
  `email`       VARCHAR(150)     DEFAULT NULL,
  `address`     TEXT             DEFAULT NULL,
  `is_active`   TINYINT(1)       NOT NULL DEFAULT 1,
  `created_at`  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: branches
-- ============================================================
CREATE TABLE IF NOT EXISTS `branches` (
  `id`              INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `organization_id` INT UNSIGNED  NOT NULL,
  `name`            VARCHAR(150)  NOT NULL,
  `code`            VARCHAR(30)   DEFAULT NULL,
  `address`         TEXT          DEFAULT NULL,
  `phone`           VARCHAR(30)   DEFAULT NULL,
  `email`           VARCHAR(150)  DEFAULT NULL,
  `is_active`       TINYINT(1)    NOT NULL DEFAULT 1,
  `created_at`      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_branches_org` (`organization_id`),
  CONSTRAINT `fk_branches_org` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: departments
-- ============================================================
CREATE TABLE IF NOT EXISTS `departments` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `branch_id`   INT UNSIGNED  NOT NULL,
  `name`        VARCHAR(150)  NOT NULL,
  `description` TEXT          DEFAULT NULL,
  `is_active`   TINYINT(1)    NOT NULL DEFAULT 1,
  `created_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_departments_branch` (`branch_id`),
  CONSTRAINT `fk_departments_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: locations
-- ============================================================
CREATE TABLE IF NOT EXISTS `locations` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `branch_id`   INT UNSIGNED  NOT NULL,
  `name`        VARCHAR(150)  NOT NULL,
  `description` TEXT          DEFAULT NULL,
  `created_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_locations_branch` (`branch_id`),
  CONSTRAINT `fk_locations_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: roles
-- ============================================================
CREATE TABLE IF NOT EXISTS `roles` (
  `id`           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `name`         VARCHAR(80)   NOT NULL UNIQUE,
  `display_name` VARCHAR(150)  NOT NULL,
  `description`  TEXT          DEFAULT NULL,
  `is_system`    TINYINT(1)    NOT NULL DEFAULT 0,
  `created_at`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: permissions
-- ============================================================
CREATE TABLE IF NOT EXISTS `permissions` (
  `id`           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `name`         VARCHAR(120)  NOT NULL UNIQUE,
  `display_name` VARCHAR(150)  NOT NULL,
  `module`       VARCHAR(80)   NOT NULL,
  `description`  TEXT          DEFAULT NULL,
  `created_at`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_permissions_module` (`module`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: role_permissions
-- ============================================================
CREATE TABLE IF NOT EXISTS `role_permissions` (
  `role_id`       INT UNSIGNED  NOT NULL,
  `permission_id` INT UNSIGNED  NOT NULL,
  `created_at`    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`role_id`, `permission_id`),
  CONSTRAINT `fk_rp_role`       FOREIGN KEY (`role_id`)       REFERENCES `roles`       (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rp_permission` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: users
-- ============================================================
CREATE TABLE IF NOT EXISTS `users` (
  `id`                   INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `uuid`                 CHAR(36)      NOT NULL UNIQUE,
  `username`             VARCHAR(80)   NOT NULL UNIQUE,
  `email`                VARCHAR(150)  NOT NULL UNIQUE,
  `password_hash`        VARCHAR(255)  NOT NULL,
  `full_name`            VARCHAR(150)  NOT NULL,
  `phone`                VARCHAR(30)   DEFAULT NULL,
  `avatar`               VARCHAR(500)  DEFAULT NULL,
  `branch_id`            INT UNSIGNED  DEFAULT NULL,
  `department_id`        INT UNSIGNED  DEFAULT NULL,
  `is_active`            TINYINT(1)    NOT NULL DEFAULT 1,
  `is_super_admin`       TINYINT(1)    NOT NULL DEFAULT 0,
  `email_verified_at`    DATETIME      DEFAULT NULL,
  `last_login_at`        DATETIME      DEFAULT NULL,
  `last_login_ip`        VARCHAR(45)   DEFAULT NULL,
  `password_changed_at`  DATETIME      DEFAULT NULL,
  `failed_login_count`   SMALLINT      NOT NULL DEFAULT 0,
  `locked_until`         DATETIME      DEFAULT NULL,
  `created_at`           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at`           DATETIME      DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_users_branch`     (`branch_id`),
  KEY `idx_users_department` (`department_id`),
  KEY `idx_users_deleted`    (`deleted_at`),
  CONSTRAINT `fk_users_branch`     FOREIGN KEY (`branch_id`)     REFERENCES `branches`     (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_users_department` FOREIGN KEY (`department_id`) REFERENCES `departments`  (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: user_roles
-- ============================================================
CREATE TABLE IF NOT EXISTS `user_roles` (
  `user_id`    INT UNSIGNED  NOT NULL,
  `role_id`    INT UNSIGNED  NOT NULL,
  `created_at` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`, `role_id`),
  CONSTRAINT `fk_ur_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ur_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: sessions  (server-side session tracking — required by auth plan §1.2)
-- ============================================================
CREATE TABLE IF NOT EXISTS `sessions` (
  `id`          CHAR(64)      NOT NULL,
  `user_id`     INT UNSIGNED  NOT NULL,
  `ip_address`  VARCHAR(45)   DEFAULT NULL,
  `user_agent`  VARCHAR(500)  DEFAULT NULL,
  `payload`     JSON          DEFAULT NULL,
  `last_activity` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sessions_user`          (`user_id`),
  KEY `idx_sessions_last_activity` (`last_activity`),
  CONSTRAINT `fk_sessions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: refresh_tokens
-- ============================================================
CREATE TABLE IF NOT EXISTS `refresh_tokens` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`     INT UNSIGNED  NOT NULL,
  `token_hash`  VARCHAR(255)  NOT NULL UNIQUE,
  `expires_at`  DATETIME      NOT NULL,
  `revoked_at`  DATETIME      DEFAULT NULL,
  `ip_address`  VARCHAR(45)   DEFAULT NULL,
  `user_agent`  VARCHAR(500)  DEFAULT NULL,
  `created_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_rt_user`    (`user_id`),
  KEY `idx_rt_expires` (`expires_at`),
  CONSTRAINT `fk_rt_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: password_reset_tokens
-- ============================================================
CREATE TABLE IF NOT EXISTS `password_reset_tokens` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`     INT UNSIGNED  NOT NULL,
  `token_hash`  VARCHAR(255)  NOT NULL UNIQUE,
  `expires_at`  DATETIME      NOT NULL,
  `used_at`     DATETIME      DEFAULT NULL,
  `created_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_prt_user`    (`user_id`),
  KEY `idx_prt_expires` (`expires_at`),
  CONSTRAINT `fk_prt_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: login_attempts  (Rate Limiting / Brute Force Protection)
-- ============================================================
CREATE TABLE IF NOT EXISTS `login_attempts` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `identifier`  VARCHAR(150)  NOT NULL,
  `ip_address`  VARCHAR(45)   NOT NULL,
  `success`     TINYINT(1)    NOT NULL DEFAULT 0,
  `created_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_la_identifier` (`identifier`),
  KEY `idx_la_ip`         (`ip_address`),
  KEY `idx_la_created`    (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: settings
-- ============================================================
CREATE TABLE IF NOT EXISTS `settings` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `key`         VARCHAR(100)  NOT NULL UNIQUE,
  `value`       TEXT          DEFAULT NULL,
  `type`        ENUM('string','integer','boolean','json') NOT NULL DEFAULT 'string',
  `group`       VARCHAR(60)   NOT NULL DEFAULT 'general',
  `description` VARCHAR(255)  DEFAULT NULL,
  `is_public`   TINYINT(1)    NOT NULL DEFAULT 0,
  `updated_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_settings_group` (`group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: audit_logs
-- ============================================================
CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id`          BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`     INT UNSIGNED     DEFAULT NULL,
  `action`      VARCHAR(80)      NOT NULL,
  `module`      VARCHAR(80)      NOT NULL,
  `target_type` VARCHAR(80)      DEFAULT NULL,
  `target_id`   INT UNSIGNED     DEFAULT NULL,
  `old_values`  JSON             DEFAULT NULL,
  `new_values`  JSON             DEFAULT NULL,
  `ip_address`  VARCHAR(45)      DEFAULT NULL,
  `user_agent`  VARCHAR(500)     DEFAULT NULL,
  `created_at`  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_al_user`    (`user_id`),
  KEY `idx_al_module`  (`module`),
  KEY `idx_al_action`  (`action`),
  KEY `idx_al_created` (`created_at`),
  CONSTRAINT `fk_al_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
-- ============================================================
-- Network Intelligence Platform (249-NIP)
-- Seed Data — Version 1.0
-- Run AFTER schema.sql
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- Default Organization
-- ============================================================
INSERT IGNORE INTO `organizations` (`id`, `name`, `description`, `is_active`) VALUES
(1, 'المؤسسة الافتراضية', 'المؤسسة الرئيسية للنظام', 1);

-- ============================================================
-- Default Branch
-- ============================================================
INSERT IGNORE INTO `branches` (`id`, `organization_id`, `name`, `code`, `is_active`) VALUES
(1, 1, 'المقر الرئيسي', 'HQ', 1);

-- ============================================================
-- System Roles (is_system = 1 → cannot be deleted)
-- ============================================================
INSERT IGNORE INTO `roles` (`id`, `name`, `display_name`, `description`, `is_system`) VALUES
(1, 'super_admin',       'Super Admin',          'صلاحيات كاملة على جميع مكونات النظام', 1),
(2, 'admin',             'Admin',                'إدارة المستخدمين والأجهزة والإعدادات', 1),
(3, 'network_engineer',  'Network Engineer',     'مراقبة الأجهزة وإجراء التشخيص',        1),
(4, 'viewer',            'Viewer',               'قراءة فقط — لا يمكنه التعديل',          1);

-- ============================================================
-- Permissions (grouped by module)
-- ============================================================

-- users module
INSERT IGNORE INTO `permissions` (`name`, `display_name`, `module`) VALUES
('users.view',           'عرض المستخدمين',            'users'),
('users.create',         'إنشاء مستخدم',              'users'),
('users.edit',           'تعديل مستخدم',              'users'),
('users.delete',         'حذف مستخدم',                'users'),
('users.toggle',         'تفعيل/تعطيل مستخدم',        'users'),
('users.reset_password', 'إعادة تعيين كلمة المرور',   'users');

-- roles module
INSERT IGNORE INTO `permissions` (`name`, `display_name`, `module`) VALUES
('roles.view',           'عرض الأدوار',               'roles'),
('roles.create',         'إنشاء دور',                 'roles'),
('roles.edit',           'تعديل دور',                 'roles'),
('roles.delete',         'حذف دور',                   'roles'),
('roles.assign',         'تعيين أدوار للمستخدمين',    'roles');

-- organizations module
INSERT IGNORE INTO `permissions` (`name`, `display_name`, `module`) VALUES
('org.view',             'عرض المؤسسة والفروع',        'organizations'),
('org.create',           'إنشاء فرع أو قسم',          'organizations'),
('org.edit',             'تعديل الهيكل التنظيمي',     'organizations'),
('org.delete',           'حذف فرع أو قسم',            'organizations');

-- devices module
INSERT IGNORE INTO `permissions` (`name`, `display_name`, `module`) VALUES
('devices.view',         'عرض الأجهزة',               'devices'),
('devices.create',       'إضافة جهاز',                'devices'),
('devices.edit',         'تعديل جهاز',                'devices'),
('devices.delete',       'حذف جهاز',                  'devices');

-- monitoring module
INSERT IGNORE INTO `permissions` (`name`, `display_name`, `module`) VALUES
('monitoring.view',      'عرض بيانات المراقبة',        'monitoring'),
('monitoring.configure', 'إعداد فترات المراقبة',       'monitoring');

-- alerts module
INSERT IGNORE INTO `permissions` (`name`, `display_name`, `module`) VALUES
('alerts.view',          'عرض التنبيهات',              'alerts'),
('alerts.manage',        'إدارة قواعد التنبيه',        'alerts'),
('alerts.acknowledge',   'تأكيد التنبيهات',            'alerts');

-- settings module
INSERT IGNORE INTO `permissions` (`name`, `display_name`, `module`) VALUES
('settings.view',        'عرض إعدادات النظام',         'settings'),
('settings.edit',        'تعديل إعدادات النظام',       'settings');

-- audit_logs module
INSERT IGNORE INTO `permissions` (`name`, `display_name`, `module`) VALUES
('audit.view',           'عرض سجل التدقيق',            'audit'),
('audit.export',         'تصدير سجل التدقيق',          'audit');

-- ============================================================
-- Assign ALL permissions → super_admin (role id = 1)
-- ============================================================
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
  SELECT 1, `id` FROM `permissions`;

-- Assign admin permissions (everything except audit export)
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
  SELECT 2, `id` FROM `permissions`
  WHERE `name` NOT IN ('audit.export');

-- Assign network_engineer permissions
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
  SELECT 3, `id` FROM `permissions`
  WHERE `name` IN (
    'devices.view', 'devices.edit',
    'monitoring.view', 'monitoring.configure',
    'alerts.view', 'alerts.acknowledge'
  );

-- Assign viewer permissions
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
  SELECT 4, `id` FROM `permissions`
  WHERE `name` IN (
    'users.view', 'devices.view',
    'monitoring.view', 'alerts.view',
    'org.view'
  );

-- ============================================================
-- Default Super Admin user
-- Password: Admin@249NIP  (bcrypt hash — change after first login)
-- ============================================================
INSERT IGNORE INTO `users` (
  `id`, `uuid`, `username`, `email`, `password_hash`,
  `full_name`, `is_active`, `is_super_admin`, `branch_id`
) VALUES (
  1,
  '00000000-0000-0000-0000-000000000001',
  'admin',
  'admin@249nip.local',
  '$2y$12$IZ1.1fQIwblL.aMdgZO8JO0vxwcSe6N9vlNzHIHvr5lSaQHr0sYJq',
  'Super Administrator',
  1, 1, 1
);

INSERT IGNORE INTO `user_roles` (`user_id`, `role_id`) VALUES (1, 1);

-- ============================================================
-- Default System Settings
-- ============================================================
INSERT IGNORE INTO `settings` (`key`, `value`, `type`, `group`, `description`, `is_public`) VALUES
('app_name',          '249-NIP',             'string',  'general',  'اسم النظام',                              1),
('app_description',   'Network Intelligence Platform', 'string', 'general', 'وصف النظام',            1),
('default_language',  'ar',                  'string',  'general',  'اللغة الافتراضية (ar / en)',              1),
('default_direction', 'rtl',                 'string',  'general',  'اتجاه النص (rtl / ltr)',                  1),
('timezone',          'Asia/Riyadh',         'string',  'general',  'المنطقة الزمنية',                         0),
('date_format',       'Y-m-d',               'string',  'general',  'تنسيق التاريخ',                           0),
('session_lifetime',  '900',                 'integer', 'security', 'مدة الجلسة بالثواني (access token)',     0),
('refresh_lifetime',  '604800',              'integer', 'security', 'مدة Refresh Token بالثواني (7 أيام)',    0),
('max_login_attempts','5',                   'integer', 'security', 'أقصى عدد محاولات تسجيل دخول فاشلة',     0),
('lockout_duration',  '900',                 'integer', 'security', 'مدة الإغلاق بعد تجاوز المحاولات (ثانية)',0),
('smtp_host',         '',                    'string',  'mail',     'عنوان خادم البريد',                       0),
('smtp_port',         '587',                 'integer', 'mail',     'منفذ خادم البريد',                        0),
('smtp_from_email',   'noreply@249nip.local','string',  'mail',     'عنوان البريد المُرسِل',                   0),
('smtp_from_name',    '249-NIP',             'string',  'mail',     'اسم المُرسِل',                            0);

SET FOREIGN_KEY_CHECKS = 1;
