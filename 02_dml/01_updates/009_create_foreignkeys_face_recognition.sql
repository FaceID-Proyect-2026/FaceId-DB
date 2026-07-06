ALTER TABLE security.face_embedding
    ADD CONSTRAINT fk_face_embedding_user
    FOREIGN KEY (id_user_app)
    REFERENCES security.user_app(id_user_app)
    ON DELETE CASCADE;
