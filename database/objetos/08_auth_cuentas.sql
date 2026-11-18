-- =====================================================================
-- KIRO - Cuentas tecnicas de autenticacion
-- MariaDB 10.4.32 · script 08 (2 de 5)
--
-- QUE HACE
--   Crea las 4 cuentas tecnicas nuevas. kiro_app ya existe y no se
--   recrea aqui.
--
-- IMPORTANTE: LAS CLAVES DE ESTE ARCHIVO SON MARCADORES.
--   Antes de ejecutarlo, reemplaza cada CAMBIAR_CLAVE_* por una clave
--   aleatoria (por ejemplo 32 bytes en hexadecimal) y NO guardes la
--   version con claves reales en Git. Despues:
--       ALTER USER 'kiro_auth'@'127.0.0.1' IDENTIFIED BY '<clave real>';
--   Y coloca la misma clave en app/config/config.php (archivo ignorado
--   por Git). En este repositorio nunca se versionan claves reales.
--
--   Si las cuentas ya existen, este script no falla: use IF NOT EXISTS
--   y luego ALTER USER para fijar la clave local.
--
-- HOST
--   127.0.0.1 (no 'localhost'): obliga a usar TCP y evita que el
--   trafico viaje por el socket/named pipe. Requiere skip-name-resolve
--   en el servidor para que el cliente sea visto como 127.0.0.1.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Lectura de credenciales para el inicio de sesion.
--    Solo puede leer id_usuario, correo y hash_contrasena.
-- ---------------------------------------------------------------------
CREATE USER IF NOT EXISTS 'kiro_auth'@'127.0.0.1'
    IDENTIFIED BY 'CAMBIAR_CLAVE_AUTH';

-- ---------------------------------------------------------------------
-- 2. Panel administrativo: lectura de usuarios y auditoria propia.
-- ---------------------------------------------------------------------
CREATE USER IF NOT EXISTS 'kiro_admin'@'127.0.0.1'
    IDENTIFIED BY 'CAMBIAR_CLAVE_ADMIN';

-- ---------------------------------------------------------------------
-- 3. Activador: NO tiene privilegios de tabla. Solo EXECUTE sobre
--    sp_activar_credencial (se concede en 10_auth_permisos.sql).
-- ---------------------------------------------------------------------
CREATE USER IF NOT EXISTS 'kiro_activador'@'127.0.0.1'
    IDENTIFIED BY 'CAMBIAR_CLAVE_ACTIVADOR';

-- ---------------------------------------------------------------------
-- 4. Definidor de procedimientos almacenados.
--    ACCOUNT LOCK: no puede iniciar sesion; solo actua como DEFINER de
--    los SP. Nunca se usa como conexion de la aplicacion.
-- ---------------------------------------------------------------------
CREATE USER IF NOT EXISTS 'kiro_sp_definer'@'127.0.0.1'
    IDENTIFIED BY 'CAMBIAR_CLAVE_DEFINER';
ALTER USER 'kiro_sp_definer'@'127.0.0.1' ACCOUNT LOCK;

-- ---------------------------------------------------------------------
-- Verificacion sugerida:
--   SELECT User, Host, is_role, password_expired FROM mysql.user
--    WHERE User IN ('kiro_app','kiro_auth','kiro_admin',
--                   'kiro_activador','kiro_sp_definer');
--   SELECT User, Host, account_locked FROM mysql.user
--    WHERE User = 'kiro_sp_definer';   -- account_locked = Y
-- ---------------------------------------------------------------------
