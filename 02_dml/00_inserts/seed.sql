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
    (uuid_generate_v4(), 'INSTRUCTOR', NOW()),
    (uuid_generate_v4(), 'APPRENTICE', NOW());
