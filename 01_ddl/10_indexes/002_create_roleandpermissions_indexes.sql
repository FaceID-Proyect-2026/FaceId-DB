CREATE INDEX idx_role_name_role
ON roleandpermission.role(name_role);

CREATE INDEX idx_role_active
ON roleandpermission.role(id_role)
WHERE deleted_at IS NULL;

CREATE INDEX idx_permission_name
ON roleandpermission.permission(name_permission);

CREATE INDEX idx_permission_active
ON roleandpermission.permission(id_permission)
WHERE deleted_at IS NULL;

CREATE INDEX idx_user_role_user
ON roleandpermission.user_role(id_user_app);

CREATE INDEX idx_user_role_role
ON roleandpermission.user_role(id_role);

CREATE INDEX idx_user_role_active
ON roleandpermission.user_role(id_user_app, id_role)
WHERE deleted_at IS NULL;

CREATE INDEX idx_role_permission_role
ON roleandpermission.role_permission(id_role);

CREATE INDEX idx_role_permission_permission
ON roleandpermission.role_permission(id_permission);

CREATE INDEX idx_role_permission_active
ON roleandpermission.role_permission(id_role, id_permission)
WHERE deleted_at IS NULL;