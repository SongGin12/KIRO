CREATE DATABASE Kiro
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
USE Kiro;
SHOW TABLES FROM Kiro;
-- 1. USUARIO
CREATE TABLE USUARIO (
    id_usuario INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(150) NOT NULL,
    fecha_registro DATETIME NOT NULL,
    hash_contrasena VARCHAR(255) NOT NULL,
    PRIMARY KEY (id_usuario),
    UNIQUE KEY uq_usuario_correo (correo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. REGISTRO_USUARIO
CREATE TABLE REGISTRO_USUARIO (
    id_registro INT NOT NULL AUTO_INCREMENT,
    metodo_registro VARCHAR(50) NOT NULL,
    estado_verificacion VARCHAR(30) NOT NULL,
    fecha_verificacion DATETIME NULL,
    id_usuario INT NOT NULL,
    PRIMARY KEY (id_registro),
    UNIQUE KEY uq_registro_usuario (id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. PERFIL_KIRO
CREATE TABLE PERFIL_KIRO (
    id_perfil INT NOT NULL AUTO_INCREMENT,
    nombre_companero VARCHAR(50) NOT NULL,
    personalidad VARCHAR(50) NOT NULL,
    estilo_comunicacion VARCHAR(50) NOT NULL,
    color_principal VARCHAR(30) NOT NULL,
    memoria_activa TINYINT(1) NOT NULL,
    id_usuario INT NOT NULL,
    PRIMARY KEY (id_perfil),
    UNIQUE KEY uq_perfil_kiro_usuario (id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. INICIO_SESION
CREATE TABLE INICIO_SESION (
    id_sesion INT NOT NULL AUTO_INCREMENT,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NULL,
    estado_sesion VARCHAR(30) NOT NULL,
    id_usuario INT NOT NULL,
    PRIMARY KEY (id_sesion),
    KEY ix_inicio_sesion_usuario_fecha (id_usuario, fecha_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. CATEGORIA
CREATE TABLE CATEGORIA (
    id_categoria INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(60) NOT NULL,
    descripcion VARCHAR(200) NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    id_usuario INT NOT NULL,
    PRIMARY KEY (id_categoria),
    UNIQUE KEY uq_categoria_id_usuario (id_categoria, id_usuario),
    KEY ix_categoria_usuario (id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. PROYECTO
CREATE TABLE PROYECTO (
    id_proyecto INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado VARCHAR(20) NOT NULL,
    prioridad VARCHAR(20) NOT NULL,
    id_usuario INT NOT NULL,
    PRIMARY KEY (id_proyecto),
    UNIQUE KEY uq_proyecto_id_usuario (id_proyecto, id_usuario),
    KEY ix_proyecto_usuario (id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. NOTA
CREATE TABLE NOTA (
    id_nota INT NOT NULL AUTO_INCREMENT,
    titulo VARCHAR(150) NOT NULL,
    contenido TEXT NOT NULL,
    fecha_creacion DATETIME NOT NULL,
    fecha_actualizacion DATETIME NOT NULL,
    id_usuario INT NOT NULL,
    id_categoria INT NULL,
    PRIMARY KEY (id_nota),
    KEY ix_nota_usuario_fecha_creacion (id_usuario, fecha_creacion),
    KEY ix_nota_categoria_usuario (id_categoria, id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. RECURSO
CREATE TABLE RECURSO (
    id_recurso INT NOT NULL AUTO_INCREMENT,
    titulo VARCHAR(150) NOT NULL,
    tipo VARCHAR(30) NOT NULL,
    url VARCHAR(500) NOT NULL,
    descripcion TEXT NOT NULL,
    fecha_registro DATETIME NOT NULL,
    id_usuario INT NOT NULL,
    id_categoria INT NULL,
    PRIMARY KEY (id_recurso),
    KEY ix_recurso_usuario_fecha (id_usuario, fecha_registro),
    KEY ix_recurso_categoria_usuario (id_categoria, id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. ACTIVIDAD
CREATE TABLE ACTIVIDAD (
    id_actividad INT NOT NULL AUTO_INCREMENT,
    titulo VARCHAR(150) NOT NULL,
    descripcion TEXT NOT NULL,
    fecha_limite DATE NOT NULL,
    estado VARCHAR(20) NOT NULL,
    prioridad VARCHAR(20) NOT NULL,
    id_proyecto INT NULL,
    id_usuario INT NOT NULL,
    PRIMARY KEY (id_actividad),
    KEY ix_actividad_usuario (id_usuario),
    KEY ix_actividad_proyecto_usuario (id_proyecto, id_usuario),
    KEY ix_actividad_proyecto_estado_fecha (id_proyecto, estado, fecha_limite)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. CITA
CREATE TABLE CITA (
    id_cita INT NOT NULL AUTO_INCREMENT,
    titulo VARCHAR(150) NOT NULL,
    descripcion TEXT NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    duracion_minutos INT NOT NULL,
    lugar VARCHAR(200) NOT NULL,
    estado VARCHAR(20) NOT NULL,
    id_usuario INT NOT NULL,
    PRIMARY KEY (id_cita),
    KEY ix_cita_usuario_fecha (id_usuario, fecha_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. RECUERDO
CREATE TABLE RECUERDO (
    id_recuerdo INT NOT NULL AUTO_INCREMENT,
    contenido TEXT NOT NULL,
    tipo VARCHAR(40) NOT NULL,
    fecha_registro DATETIME NOT NULL,
    autorizado TINYINT(1) NOT NULL,
    estado VARCHAR(20) NOT NULL,
    id_usuario INT NOT NULL,
    PRIMARY KEY (id_recuerdo),
    KEY ix_recuerdo_usuario_fecha (id_usuario, fecha_registro)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12. HISTORIAL_ACCION
CREATE TABLE HISTORIAL_ACCION (
    id_accion INT NOT NULL AUTO_INCREMENT,
    tipo_accion VARCHAR(50) NOT NULL,
    entidad_afectada VARCHAR(50) NOT NULL,
    id_registro_afectado INT NULL,
    descripcion TEXT NOT NULL,
    fecha_accion DATETIME NOT NULL,
    actor VARCHAR(20) NOT NULL,
    resultado VARCHAR(20) NOT NULL,
    id_usuario INT NOT NULL,
    PRIMARY KEY (id_accion),
    KEY ix_historial_usuario_fecha (id_usuario, fecha_accion),
    KEY ix_historial_entidad_registro (entidad_afectada, id_registro_afectado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- CLAVES FORANEAS SIMPLES

ALTER TABLE REGISTRO_USUARIO
ADD CONSTRAINT fk_registro_usuario_usuario
FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario)
ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE INICIO_SESION
ADD CONSTRAINT fk_inicio_sesion_usuario
FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario)
ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE PERFIL_KIRO
ADD CONSTRAINT fk_perfil_kiro_usuario
FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario)
ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE CITA
ADD CONSTRAINT fk_cita_usuario
FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario)
ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE NOTA
ADD CONSTRAINT fk_nota_usuario
FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario)
ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE PROYECTO
ADD CONSTRAINT fk_proyecto_usuario
FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario)
ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE ACTIVIDAD
ADD CONSTRAINT fk_actividad_usuario
FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario)
ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE CATEGORIA
ADD CONSTRAINT fk_categoria_usuario
FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario)
ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE RECURSO
ADD CONSTRAINT fk_recurso_usuario
FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario)
ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE RECUERDO
ADD CONSTRAINT fk_recuerdo_usuario
FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario)
ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE HISTORIAL_ACCION
ADD CONSTRAINT fk_historial_accion_usuario
FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario)
ON DELETE RESTRICT ON UPDATE RESTRICT;

-- CLAVES FORANEAS COMPUESTAS

ALTER TABLE NOTA
ADD CONSTRAINT fk_nota_categoria_usuario
FOREIGN KEY (id_categoria, id_usuario)
REFERENCES CATEGORIA(id_categoria, id_usuario)
ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE RECURSO
ADD CONSTRAINT fk_recurso_categoria_usuario
FOREIGN KEY (id_categoria, id_usuario)
REFERENCES CATEGORIA(id_categoria, id_usuario)
ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE ACTIVIDAD
ADD CONSTRAINT fk_actividad_proyecto_usuario
FOREIGN KEY (id_proyecto, id_usuario)
REFERENCES PROYECTO(id_proyecto, id_usuario)
ON DELETE RESTRICT ON UPDATE RESTRICT;

-- INSERTS USUARIO
USE Kiro;

INSERT INTO USUARIO
(nombre, correo, fecha_registro, hash_contrasena)
VALUES
('Carlos Mendoza', 'carlos.mendoza@example.com', '2026-10-01 09:00:00', 'hash_prueba_001'),
('Ana Flores', 'ana.flores@example.com', '2026-10-02 10:30:00', 'hash_prueba_002'),
('Diego Vargas', 'diego.vargas@example.com', '2026-10-03 11:00:00', 'hash_prueba_003'),
('Lucia Quispe', 'lucia.quispe@example.com', '2026-10-04 08:45:00', 'hash_prueba_004'),
('Miguel Rojas', 'miguel.rojas@example.com', '2026-10-05 14:00:00', 'hash_prueba_005'),
('Sofia Ramirez', 'sofia.ramirez@example.com', '2026-10-06 15:30:00', 'hash_prueba_006'),
('Andres Choque', 'andres.choque@example.com', '2026-10-07 09:15:00', 'hash_prueba_007'),
('Valeria Paredes', 'valeria.paredes@example.com', '2026-10-08 12:00:00', 'hash_prueba_008'),
('Javier Morales', 'javier.morales@example.com', '2026-10-09 16:20:00', 'hash_prueba_009'),
('Camila Torres', 'camila.torres@example.com', '2026-10-10 10:00:00', 'hash_prueba_010');

SELECT * FROM USUARIO;

-- INSERTS REGISTRO_USUARIO
INSERT INTO REGISTRO_USUARIO
(metodo_registro, estado_verificacion, fecha_verificacion, id_usuario)
VALUES
('Correo electrónico', 'Verificado', '2026-10-01 09:10:00', 1),
('Google', 'Verificado', '2026-10-02 10:40:00', 2),
('Correo electrónico', 'Pendiente', NULL, 3),
('Google', 'Verificado', '2026-10-04 09:00:00', 4),
('Correo electrónico', 'Verificado', '2026-10-05 14:10:00', 5),
('Google', 'Pendiente', NULL, 6),
('Correo electrónico', 'Verificado', '2026-10-07 09:30:00', 7),
('Google', 'Verificado', '2026-10-08 12:15:00', 8),
('Correo electrónico', 'Pendiente', NULL, 9),
('Google', 'Verificado', '2026-10-10 10:15:00', 10);

SELECT * FROM REGISTRO_USUARIO;

-- INSERTS perfil_kiro
INSERT INTO PERFIL_KIRO
(nombre_companero, personalidad, estilo_comunicacion, color_principal, memoria_activa, id_usuario)
VALUES
('Kiro', 'Amigable', 'Cercano', 'Azul', 1, 1),
('Lumi', 'Tranquila', 'Empatico', 'Lila', 1, 2),
('Niko', 'Divertida', 'Informal', 'Amarillo', 1, 3),
('Mika', 'Reflexiva', 'Motivador', 'Verde', 1, 4),
('Ari', 'Serena', 'Directo', 'Celeste', 0, 5),
('Kiro', 'Optimista', 'Cercano', 'Rosa', 1, 6),
('Luna', 'Creativa', 'Informal', 'Violeta', 1, 7),
('Tao', 'Paciente', 'Reflexivo', 'Naranja', 0, 8),
('Milo', 'Alegre', 'Motivador', 'Turquesa', 1, 9),
('Yuki', 'Comprensiva', 'Cercano', 'Blanco', 1, 10);

SELECT * FROM PERFIL_KIRO;

-- INSERTS inicio_sesion
INSERT INTO INICIO_SESION
(fecha_inicio, fecha_fin, estado_sesion, id_usuario)
VALUES
('2026-11-01 08:00:00', '2026-11-01 09:30:00', 'Cerrada', 1),
('2026-11-01 09:00:00', '2026-11-01 10:15:00', 'Cerrada', 2),
('2026-11-02 10:00:00', NULL, 'Activa', 3),
('2026-11-02 11:30:00', '2026-11-02 12:00:00', 'Cerrada', 4),
('2026-11-03 07:45:00', '2026-11-03 08:30:00', 'Cerrada', 5),
('2026-11-03 14:00:00', NULL, 'Activa', 6),
('2026-11-04 15:00:00', '2026-11-04 16:20:00', 'Cerrada', 7),
('2026-11-05 08:30:00', '2026-11-05 09:00:00', 'Cerrada', 8),
('2026-11-05 17:00:00', NULL, 'Activa', 9),
('2026-11-06 10:00:00', '2026-11-06 11:45:00', 'Cerrada', 10);

SELECT * FROM INICIO_SESION;

-- INSERTS categoria
INSERT INTO CATEGORIA
(nombre, descripcion, tipo, id_usuario)
VALUES
('Estudios', 'Organización de materias y actividades académicas', 'Personal', 1),
('Trabajo', 'Actividades y responsabilidades laborales', 'Personal', 2),
('Salud', 'Hábitos y seguimiento del bienestar', 'Personal', 3),
('Finanzas', 'Control de gastos e ingresos personales', 'Personal', 4),
('Lecturas', 'Libros y materiales de lectura', 'Personal', 5),
('Proyectos', 'Ideas y proyectos personales', 'Personal', 6),
('Rutinas', 'Hábitos y actividades diarias', 'Personal', 7),
('Inspiración', 'Ideas y contenido motivacional', 'Personal', 8),
('Ocio', 'Actividades recreativas y pasatiempos', 'Personal', 9),
('Aprendizaje', 'Materiales y actividades de aprendizaje', 'Personal', 10);

SELECT * FROM CATEGORIA;

-- INSERTS proyecto
INSERT INTO PROYECTO
(nombre, descripcion, fecha_inicio, fecha_fin, estado, prioridad, id_usuario)
VALUES
('Proyecto universitario', 'Desarrollo de un trabajo académico', '2026-10-01', '2026-12-15', 'En progreso', 'Alta', 1),
('Capacitación laboral', 'Preparación para nuevas responsabilidades', '2026-10-05', '2026-11-30', 'En progreso', 'Media', 2),
('Plan de bienestar', 'Organización de hábitos saludables', '2026-10-10', '2026-12-31', 'Pendiente', 'Alta', 3),
('Control financiero', 'Organización del presupuesto personal', '2026-09-15', '2026-12-20', 'En progreso', 'Alta', 4),
('Club de lectura', 'Lectura y análisis de libros', '2026-10-01', '2026-11-30', 'Completado', 'Baja', 5),
('Aplicación personal', 'Diseño de una aplicación para uso propio', '2026-10-12', '2027-01-15', 'En progreso', 'Alta', 6),
('Rutina de ejercicios', 'Planificación de actividad física semanal', '2026-10-15', '2026-12-15', 'Pendiente', 'Media', 7),
('Blog personal', 'Creación de contenido de inspiración', '2026-09-20', '2026-12-10', 'En progreso', 'Media', 8),
('Aprender fotografía', 'Práctica de técnicas de fotografía', '2026-10-20', '2026-12-20', 'Pendiente', 'Baja', 9),
('Curso de idiomas', 'Estudio y práctica de un nuevo idioma', '2026-09-01', '2026-11-01', 'Completado', 'Media', 10);

SELECT * FROM PROYECTO;

-- INSERTS actividad
INSERT INTO ACTIVIDAD
(titulo, descripcion, fecha_limite, estado, prioridad, id_proyecto, id_usuario)
VALUES
('Preparar informe', 'Redactar el informe del proyecto universitario', '2026-11-15', 'Pendiente', 'Alta', 1, 1),
('Revisar capacitación', 'Completar los materiales de capacitación', '2026-11-18', 'En progreso', 'Media', 2, 2),
('Organizar alimentación', 'Preparar un plan de alimentación semanal', '2026-11-20', 'Pendiente', 'Alta', 3, 3),
('Registrar gastos', 'Actualizar los gastos del presupuesto', '2026-11-12', 'Completada', 'Alta', 4, 4),
('Terminar lectura', 'Finalizar el libro seleccionado', '2026-11-10', 'Completada', 'Baja', 5, 5),
('Diseñar pantalla', 'Preparar el diseño inicial de la aplicación', '2026-11-25', 'En progreso', 'Alta', 6, 6),
('Planificar rutina', 'Organizar los ejercicios de la semana', '2026-11-22', 'Pendiente', 'Media', 7, 7),
('Redactar publicación', 'Preparar una nueva entrada para el blog', '2026-11-28', 'En progreso', 'Media', 8, 8),
('Comprar materiales', 'Adquirir materiales para uso personal', '2026-11-16', 'Pendiente', 'Baja', NULL, 9),
('Organizar escritorio', 'Ordenar documentos y archivos personales', '2026-11-17', 'Pendiente', 'Media', NULL, 10);

SELECT * FROM ACTIVIDAD;

-- INSERTS cita
INSERT INTO CITA
(titulo, descripcion, fecha_inicio, duracion_minutos, lugar, estado, id_usuario)
VALUES
('Reunión académica', 'Revisión del avance del proyecto universitario', '2026-11-12 09:00:00', 60, 'Universidad', 'Pendiente', 1),
('Entrevista laboral', 'Entrevista para una oportunidad de trabajo', '2026-11-13 10:00:00', 45, 'Oficina central', 'Confirmada', 2),
('Control médico', 'Consulta médica de rutina', '2026-11-14 08:30:00', 30, 'Centro médico', 'Confirmada', 3),
('Asesoría financiera', 'Revisión del presupuesto personal', '2026-11-15 15:00:00', 60, 'Banco', 'Pendiente', 4),
('Club de lectura', 'Encuentro para comentar un libro', '2026-11-16 17:00:00', 90, 'Biblioteca', 'Confirmada', 5),
('Revisión de diseño', 'Evaluación del diseño de la aplicación', '2026-11-17 11:00:00', 45, 'En línea', 'Pendiente', 6),
('Entrenamiento', 'Sesión de actividad física', '2026-11-18 07:00:00', 60, 'Gimnasio', 'Confirmada', 7),
('Reunión editorial', 'Planificación de nuevas publicaciones', '2026-11-19 16:00:00', 60, 'En línea', 'Cancelada', 8),
('Sesión fotográfica', 'Práctica de fotografía en exteriores', '2026-11-20 14:00:00', 120, 'Parque', 'Pendiente', 9),
('Clase de idiomas', 'Práctica de conversación', '2026-11-21 09:30:00', 60, 'Centro de idiomas', 'Confirmada', 10);

SELECT * FROM CITA;

-- INSERTS NOTA
INSERT INTO NOTA
(titulo, contenido, fecha_creacion, fecha_actualizacion, id_usuario, id_categoria)
VALUES
('Avance del proyecto', 'Se completó la primera parte del trabajo universitario.', '2026-11-01 10:00:00', '2026-11-02 11:00:00', 1, 1),
('Pendientes laborales', 'Revisar documentos y preparar el informe semanal.', '2026-11-02 09:00:00', '2026-11-03 09:30:00', 2, 2),
('Hábitos saludables', 'Mantener una rutina de descanso y alimentación equilibrada.', '2026-11-03 08:00:00', '2026-11-03 08:00:00', 3, 3),
('Gastos del mes', 'Registrar los gastos realizados durante noviembre.', '2026-11-04 12:00:00', '2026-11-05 12:30:00', 4, 4),
('Libros pendientes', 'Leer los capítulos restantes del libro seleccionado.', '2026-11-05 15:00:00', '2026-11-06 15:00:00', 5, 5),
('Ideas para la aplicación', 'Agregar mejoras a la propuesta de diseño.', '2026-11-06 10:00:00', '2026-11-07 10:30:00', 6, 6),
('Rutina semanal', 'Organizar las actividades físicas de la semana.', '2026-11-07 07:00:00', '2026-11-07 07:00:00', 7, 7),
('Frases inspiradoras', 'Guardar ideas para futuras publicaciones.', '2026-11-08 16:00:00', '2026-11-09 16:00:00', 8, 8),
('Ideas recreativas', 'Buscar nuevas actividades para el tiempo libre.', '2026-11-09 14:00:00', '2026-11-10 14:00:00', 9, 9),
('Palabras nuevas', 'Registrar vocabulario aprendido durante las clases.', '2026-11-10 11:00:00', '2026-11-10 11:00:00', 10, 10);

SELECT * FROM NOTA;

-- INSERTS recurso
INSERT INTO RECURSO
(titulo, tipo, url, descripcion, fecha_registro, id_usuario, id_categoria)
VALUES
('Guía de gestión de proyectos', 'Documento', 'https://example.com/guia-proyectos', 'Material de apoyo para organizar proyectos académicos.', '2026-11-01 09:00:00', 1, 1),
('Curso de productividad', 'Curso', 'https://example.com/productividad', 'Curso sobre organización y productividad laboral.', '2026-11-02 10:00:00', 2, 2),
('Guía de alimentación saludable', 'Documento', 'https://example.com/alimentacion', 'Información sobre hábitos alimenticios saludables.', '2026-11-03 11:00:00', 3, 3),
('Plantilla de presupuesto', 'Plantilla', 'https://example.com/presupuesto', 'Plantilla para organizar ingresos y gastos.', '2026-11-04 12:00:00', 4, 4),
('Biblioteca digital', 'Sitio web', 'https://example.com/biblioteca', 'Repositorio de libros y materiales de lectura.', '2026-11-05 13:00:00', 5, 5),
('Tutorial de diseño UI', 'Video', 'https://example.com/diseno-ui', 'Tutorial introductorio de diseño de interfaces.', '2026-11-06 14:00:00', 6, 6),
('Guía de entrenamiento', 'Documento', 'https://example.com/entrenamiento', 'Material de referencia para rutinas físicas.', '2026-11-07 15:00:00', 7, 7),
('Banco de frases', 'Sitio web', 'https://example.com/frases', 'Colección de frases e ideas inspiradoras.', '2026-11-08 16:00:00', 8, 8),
('Curso de fotografía', 'Curso', 'https://example.com/fotografia', 'Material introductorio sobre fotografía.', '2026-11-09 17:00:00', 9, 9),
('Diccionario de idiomas', 'Sitio web', 'https://example.com/diccionario', 'Recurso para consultar vocabulario y traducciones.', '2026-11-10 18:00:00', 10, 10);

SELECT * FROM RECURSO;

-- INSERT recuerdo
INSERT INTO RECUERDO
(contenido, tipo, fecha_registro, autorizado, estado, id_usuario)
VALUES
('El usuario estudia Ingeniería en Sistemas.', 'Personal', '2026-11-01 10:00:00', 1, 'Activo', 1),
('Prefiere organizar sus actividades por la mañana.', 'Preferencia', '2026-11-02 11:00:00', 1, 'Activo', 2),
('Tiene interés en mejorar sus hábitos de alimentación.', 'Interes', '2026-11-03 12:00:00', 1, 'Activo', 3),
('Está organizando sus finanzas personales.', 'Personal', '2026-11-04 13:00:00', 1, 'Activo', 4),
('Le gusta leer novelas.', 'Preferencia', '2026-11-05 14:00:00', 1, 'Activo', 5),
('Está desarrollando una aplicación personal.', 'Proyecto', '2026-11-06 15:00:00', 1, 'Activo', 6),
('Prefiere realizar ejercicio por las mañanas.', 'Preferencia', '2026-11-07 16:00:00', 0, 'Pendiente', 7),
('Tiene interés en crear contenido motivacional.', 'Interes', '2026-11-08 17:00:00', 1, 'Activo', 8),
('Disfruta realizar actividades fotográficas.', 'Preferencia', '2026-11-09 18:00:00', 0, 'Pendiente', 9),
('Está aprendiendo un nuevo idioma.', 'Aprendizaje', '2026-11-10 19:00:00', 1, 'Activo', 10);

SELECT * FROM RECUERDO;

-- INSERTS historial accion
INSERT INTO HISTORIAL_ACCION
(tipo_accion, entidad_afectada, id_registro_afectado, descripcion,
 fecha_accion, actor, resultado, id_usuario)
VALUES
('CREACION', 'NOTA', 1, 'El usuario creó una nota de estudios.',
 '2026-11-01 09:15:00', 'USUARIO', 'EXITOSO', 1),

('ACTUALIZACION', 'PROYECTO', 2, 'Se actualizó el estado del proyecto laboral.',
 '2026-11-02 10:30:00', 'USUARIO', 'EXITOSO', 2),

('INICIO_SESION', 'INICIO_SESION', 3, 'El usuario inició una sesión.',
 '2026-11-03 08:00:00', 'USUARIO', 'EXITOSO', 3),

('CREACION', 'CITA', 4, 'Se registró una cita de asesoría financiera.',
 '2026-11-04 11:45:00', 'USUARIO', 'EXITOSO', 4),

('ACTUALIZACION', 'ACTIVIDAD', 5, 'Se actualizó una actividad pendiente.',
 '2026-11-05 14:20:00', 'USUARIO', 'EXITOSO', 5),

('CREACION', 'RECURSO', 6, 'Se agregó un recurso al perfil del usuario.',
 '2026-11-06 16:10:00', 'USUARIO', 'EXITOSO', 6),

('ACTUALIZACION', 'RECUERDO', 7, 'Se modificó el estado de autorización de un recuerdo.',
 '2026-11-07 09:40:00', 'KIRO', 'EXITOSO', 7),

('CREACION', 'CATEGORIA', 8, 'Se creó una categoría personal.',
 '2026-11-08 12:00:00', 'USUARIO', 'EXITOSO', 8),

('ELIMINACION', 'NOTA', 9, 'Se registró la eliminación de una nota.',
 '2026-11-09 15:30:00', 'USUARIO', 'EXITOSO', 9),

('ACTUALIZACION', 'PERFIL_KIRO', 10, 'Se actualizaron las preferencias del compañero KIRO.',
 '2026-11-10 17:00:00', 'KIRO', 'EXITOSO', 10);

 SELECT * FROM HISTORIAL_ACCION;
 -- Ver las 120 Inserciones
 SELECT 'USUARIO' AS tabla, COUNT(*) AS registros FROM USUARIO
UNION ALL
SELECT 'REGISTRO_USUARIO', COUNT(*) FROM REGISTRO_USUARIO
UNION ALL
SELECT 'INICIO_SESION', COUNT(*) FROM INICIO_SESION
UNION ALL
SELECT 'PERFIL_KIRO', COUNT(*) FROM PERFIL_KIRO
UNION ALL
SELECT 'CITA', COUNT(*) FROM CITA
UNION ALL
SELECT 'NOTA', COUNT(*) FROM NOTA
UNION ALL
SELECT 'PROYECTO', COUNT(*) FROM PROYECTO
UNION ALL
SELECT 'ACTIVIDAD', COUNT(*) FROM ACTIVIDAD
UNION ALL
SELECT 'CATEGORIA', COUNT(*) FROM CATEGORIA
UNION ALL
SELECT 'RECURSO', COUNT(*) FROM RECURSO
UNION ALL
SELECT 'RECUERDO', COUNT(*) FROM RECUERDO
UNION ALL
SELECT 'HISTORIAL_ACCION', COUNT(*) FROM HISTORIAL_ACCION;