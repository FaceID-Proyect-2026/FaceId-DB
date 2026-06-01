ALTER TABLE roleandpermission.user_role
ADD CONSTRAINT fk_user_role_user
FOREIGN KEY (id_users)
REFERENCES security.user_app (id_users);

ALTER TABLE roleandpermission.user_role
ADD CONSTRAINT fk_user_role_role
FOREIGN KEY (id_role)
REFERENCES roleandpermission.role (id_role);

ALTER TABLE roleandpermission.role_permission
ADD CONSTRAINT fk_role_permission_role
FOREIGN KEY (id_role)
REFERENCES roleandpermission.role (id_role);

ALTER TABLE roleandpermission.role_permission
ADD CONSTRAINT fk_role_permission_permission
FOREIGN KEY (id_permission)
REFERENCES roleandpermission.permission (id_permission);