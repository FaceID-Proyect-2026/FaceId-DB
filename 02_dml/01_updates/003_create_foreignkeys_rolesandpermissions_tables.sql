-- FK: user_role -> users
ALTER TABLE rolesandpermissions.user_role
ADD CONSTRAINT fk_user_role_user
FOREIGN KEY (id_users)
REFERENCES security.users (id_users);

-- FK: user_role -> role
ALTER TABLE rolesandpermissions.user_role
ADD CONSTRAINT fk_user_role_role
FOREIGN KEY (id_role)
REFERENCES rolesandpermissions.role (id_role);

-- FK: role_permission -> role
ALTER TABLE rolesandpermissions.role_permission
ADD CONSTRAINT fk_role_permission_role
FOREIGN KEY (id_role)
REFERENCES rolesandpermissions.role (id_role);

-- FK: role_permission -> permission
ALTER TABLE rolesandpermissions.role_permission
ADD CONSTRAINT fk_role_permission_permission
FOREIGN KEY (id_permission)
REFERENCES rolesandpermissions.permission (id_permission);