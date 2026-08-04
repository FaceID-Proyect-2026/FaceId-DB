ALTER TABLE roleandpermission.role_permission
DROP CONSTRAINT fk_role_permission_permission;

ALTER TABLE roleandpermission.role_permission
DROP CONSTRAINT fk_role_permission_role;

ALTER TABLE roleandpermission.user_role
DROP CONSTRAINT fk_user_role_role;

ALTER TABLE roleandpermission.user_role
DROP CONSTRAINT fk_user_role_user;