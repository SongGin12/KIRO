-- =====================================================================
-- KIRO - Verificacion de autenticacion (SOLO LECTURA)
-- MariaDB 10.4.32 · script 11 (5 de 5)
--
-- No modifica nada. Sirve para comprobar el estado despues de aplicar
-- 07 a 10 y antes de ejecutar las pruebas funcionales.
-- =====================================================================

USE `Kiro`;

-- 1. Las 12 tablas academicas siguen siendo 12.
SELECT COUNT(*) AS tablas_academicas
  FROM information_schema.TABLES
 WHERE TABLE_SCHEMA = 'Kiro'
   AND TABLE_TYPE = 'BASE TABLE'
   AND TABLE_NAME IN ('usuario', 'perfil_kiro', 'registro_usuario',
                      'inicio_sesion', 'categoria', 'nota', 'recuerdo',
                      'recurso', 'proyecto', 'actividad', 'cita',
                      'historial_accion');

-- 2. Extensiones de identidad presentes (deben ser 3).
SELECT COUNT(*) AS tablas_soporte
  FROM information_schema.TABLES
 WHERE TABLE_SCHEMA = 'Kiro'
   AND TABLE_NAME IN ('administrador', 'accion_admin', 'codigo_activacion');

-- 3. Procedimientos con su DEFINER (no debe ser root).
SELECT ROUTINE_NAME, DEFINER, SECURITY_TYPE
  FROM information_schema.ROUTINES
 WHERE ROUTINE_SCHEMA = 'Kiro'
   AND ROUTINE_NAME IN ('sp_emitir_codigo_activacion', 'sp_activar_credencial');

-- 4. Cuentas tecnicas y estado de bloqueo.
SELECT User, Host, account_locked
  FROM mysql.user
 WHERE User IN ('kiro_app', 'kiro_auth', 'kiro_admin',
                'kiro_activador', 'kiro_sp_definer')
 ORDER BY User;

-- 5. NINGUNA cuenta de aplicacion con DML sobre tablas privadas.
--    Resultado esperado: 0 filas.
SELECT GRANTEE, TABLE_NAME, PRIVILEGE_TYPE
  FROM information_schema.TABLE_PRIVILEGES
 WHERE TABLE_SCHEMA = 'Kiro'
   AND TABLE_NAME IN ('nota', 'recuerdo', 'cita', 'proyecto', 'actividad',
                      'recurso', 'categoria', 'historial_accion')
   AND PRIVILEGE_TYPE IN ('INSERT', 'UPDATE', 'DELETE')
   AND GRANTEE <> "'kiro_sp_definer'@'127.0.0.1'"
 ORDER BY GRANTEE, TABLE_NAME;

-- 6. Privilegios por columna de escritura: solo las 4 tablas permitidas
--    (usuario, perfil_kiro, registro_usuario, inicio_sesion).
SELECT GRANTEE, TABLE_NAME, COLUMN_NAME, PRIVILEGE_TYPE
  FROM information_schema.COLUMN_PRIVILEGES
 WHERE TABLE_SCHEMA = 'Kiro'
   AND PRIVILEGE_TYPE IN ('INSERT', 'UPDATE')
 ORDER BY GRANTEE, TABLE_NAME, COLUMN_NAME;

-- 7. Conteos que no deben cambiar durante la entrega.
SELECT
  (SELECT COUNT(*) FROM `usuario`)          AS usuarios,
  (SELECT COUNT(*) FROM `perfil_kiro`)      AS perfiles,
  (SELECT COUNT(*) FROM `registro_usuario`) AS registros,
  (SELECT COUNT(*) FROM `inicio_sesion`)    AS sesiones,
  (SELECT COUNT(*) FROM `categoria`)        AS categorias,
  (SELECT COUNT(*) FROM `nota`)             AS notas,
  (SELECT COUNT(*) FROM `recuerdo`)         AS recuerdos,
  (SELECT COUNT(*) FROM `recurso`)          AS recursos,
  (SELECT COUNT(*) FROM `proyecto`)         AS proyectos,
  (SELECT COUNT(*) FROM `actividad`)        AS actividades,
  (SELECT COUNT(*) FROM `cita`)             AS citas,
  (SELECT COUNT(*) FROM `historial_accion`) AS historial;

-- 8. Ids 1 y 2 activados; ids 3 a 10 intactos (relleno de 15 caracteres).
SELECT `id_usuario`,
       CASE WHEN `hash_contrasena` LIKE '$2y$%'
              OR `hash_contrasena` LIKE '$2a$%'
              OR `hash_contrasena` LIKE '$2b$%'
              OR `hash_contrasena` LIKE '$argon2%'
            THEN 'hash_valido' ELSE 'sin_activar' END AS estado,
       CHAR_LENGTH(`hash_contrasena`) AS longitud
  FROM `usuario`
 ORDER BY `id_usuario`;
