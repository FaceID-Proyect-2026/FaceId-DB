-- ROLE
CREATE TABLE rolesandpermissions.role (
    id_role UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name_role VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_name_role 
        CHECK (name_role IN ('APPRENTICE','INSTRUCTOR','ADMINISTRATOR'))
);

-- PERMISSION
CREATE TABLE rolesandpermissions.permission (
    id_permission UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name_permission VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ
);

-- USER_ROLE (N:M)
CREATE TABLE rolesandpermissions.user_role (
    id_user_role UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_users UUID NOT NULL,
    id_role UUID NOT NULL,
    assignment_date DATE,
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT uq_user_role UNIQUE (id_users, id_role)
);

-- ROLE_PERMISSION (N:M)
CREATE TABLE rolesandpermissions.role_permission (
    id_role_permission UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_role UUID NOT NULL,
    id_permission UUID NOT NULL,
    assignment_date DATE,
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT uq_role_permission UNIQUE (id_role, id_permission)
);