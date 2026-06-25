INSERT INTO security.type_document
(id_type_document, name, abbreviation)
VALUES
(gen_random_uuid(), 'CITIZENSHIP CARD', 'CC');

INSERT INTO security.type_document
(id_type_document, name, abbreviation)
VALUES
(gen_random_uuid(), 'FOREIGNER IDENTITY CARD', 'CE');

INSERT INTO security.type_document
(id_type_document, name, abbreviation)
VALUES
(gen_random_uuid(), 'IDENTITY CARD', 'TI');

INSERT INTO security.type_document
(id_type_document, name, abbreviation)
VALUES
(gen_random_uuid(), 'PASSPORT', 'PAS');

INSERT INTO roleandpermission.role (id_role, name_role, created_at)
VALUES
    (uuid_generate_v4(), 'ADMINISTRATOR', NOW()),
    (uuid_generate_v4(), 'COORDINATOR', NOW()),
    (uuid_generate_v4(), 'INSTRUCTOR', NOW()),
    (uuid_generate_v4(), 'APPRENTICE', NOW());

    INSERT INTO roleandpermission.permission (
    id_permission,
    name_permission,
    description,
    created_at
)
VALUES
(uuid_generate_v4(), 'VIEW_OWN_PROFILE', 'Ver perfil propio', NOW()),
(uuid_generate_v4(), 'EDIT_OWN_PROFILE', 'Editar perfil propio', NOW()),
(uuid_generate_v4(), 'VIEW_OWN_ATTENDANCE', 'Ver asistencia propia', NOW()),
(uuid_generate_v4(), 'VIEW_FICHA_ATTENDANCE', 'Ver asistencia de ficha', NOW()),
(uuid_generate_v4(), 'MANAGE_SCHEDULES', 'Gestionar horarios', NOW()),
(uuid_generate_v4(), 'MANAGE_USERS', 'Gestionar usuarios', NOW()),
(uuid_generate_v4(), 'MANAGE_ROLES', 'Gestionar roles', NOW()),
(uuid_generate_v4(), 'MANAGE_ENVIRONMENTS', 'Gestionar ambientes', NOW()),
(uuid_generate_v4(), 'MANAGE_FICHAS', 'Gestionar fichas', NOW()),
(uuid_generate_v4(), 'MANAGE_TRAINING_PROGRAMS', 'Gestionar programas de formacion', NOW());

INSERT INTO roleandpermission.role_permission (id_role_permission, id_role, id_permission, assignment_date, assigned_at, created_at)
SELECT uuid_generate_v4(), r.id_role, p.id_permission, NOW(), NOW(), NOW()
FROM roleandpermission.role r
CROSS JOIN roleandpermission.permission p
WHERE r.name_role = 'COORDINATOR'
AND p.name_permission IN (
    'VIEW_OWN_PROFILE',
    'EDIT_OWN_PROFILE',
    'VIEW_FICHA_ATTENDANCE',
    'MANAGE_SCHEDULES',
    'MANAGE_USERS',
    'MANAGE_ROLES',
    'MANAGE_ENVIRONMENTS',
    'MANAGE_FICHAS',
    'MANAGE_TRAINING_PROGRAMS'
);

INSERT INTO roleandpermission.role_permission (id_role_permission, id_role, id_permission, assignment_date, assigned_at, created_at)
SELECT uuid_generate_v4(), r.id_role, p.id_permission, NOW(), NOW(), NOW()
FROM roleandpermission.role r
CROSS JOIN roleandpermission.permission p
WHERE r.name_role = 'INSTRUCTOR'
AND p.name_permission IN (
    'VIEW_OWN_PROFILE',
    'EDIT_OWN_PROFILE',
    'VIEW_OWN_ATTENDANCE',
    'VIEW_FICHA_ATTENDANCE',
    'MANAGE_SCHEDULES'
);

INSERT INTO roleandpermission.role_permission (id_role_permission, id_role, id_permission, assignment_date, assigned_at, created_at)
SELECT uuid_generate_v4(), r.id_role, p.id_permission, NOW(), NOW(), NOW()
FROM roleandpermission.role r
CROSS JOIN roleandpermission.permission p
WHERE r.name_role = 'APPRENTICE'
AND p.name_permission IN (
    'VIEW_OWN_PROFILE',
    'EDIT_OWN_PROFILE',
    'VIEW_OWN_ATTENDANCE'
);
