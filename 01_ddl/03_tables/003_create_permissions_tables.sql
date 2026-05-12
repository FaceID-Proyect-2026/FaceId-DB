CREATE TABLE permissions."role" (
    id_role UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name_role VARCHAR(20),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_name_role 
        CHECK (name_role 
        IN ('APPRENTICE','INSTRUCTOR','ADMINISTRATOR'))
);

CREATE TABLE permissions.permission (
    id_permission UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name_permission VARCHAR(100),
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
);

CREATE TABLE permissions.user_role (
    id_user_role UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_user UUID,
    id_role UUID,
    fechaAsignacion DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT fk_user_role_user
        FOREIGN KEY (id_user) 
        REFERENCES security."user"(id_user),
    CONSTRAINT fk_user_role_role
        FOREIGN KEY (id_role)
        REFERENCES permissions."role"(id_role)
);

CREATE TABLE permissions.role_permission (
    id_role_permission UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_role UUID NOT NULL,
    id_permission UUID NOT NULL,
    assignment_date DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT fk_role_permission_role
        FOREIGN KEY (id_role)
        REFERENCES permissions."role"(id_role),
    CONSTRAINT fk_role_permission_permission
        FOREIGN KEY (id_permission)
        REFERENCES permissions.permission(id_permission)
);