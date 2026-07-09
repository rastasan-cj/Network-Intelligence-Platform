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
