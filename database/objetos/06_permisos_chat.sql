-- =====================================================================
-- KIRO (evolucion chat) - Permisos de escritura del chat
-- Preparado para MariaDB 10.4.32. ETAPA 2 - script 3 de 4.
--
-- OBJETIVO
--   Permitir que el backend PHP (usuario kiro_app@127.0.0.1) guarde y
--   consulte conversaciones y mensajes con minimo privilegio.
--
-- ADVERTENCIA
--   Ejecutar SOLO con cuenta administradora, DESPUES de
--   database/chat/02_tablas_chat.sql (los GRANT exigen que las tablas
--   existan).
--
-- POR QUE DIRECTOS AL USUARIO Y NO POR ROL NUEVO
--   MariaDB 10.4.32 NO tiene la variable activate_all_roles_on_login
--   (verificado: error 1193). Al conectar, solo se activa el rol
--   predeterminado (rol_kiro_app); un rol nuevo quedaria INACTIVO en
--   las sesiones PDO y los INSERT del chat fallarian. Se concede
--   directamente al usuario, sin tocar rol_kiro_app ni este rol de
--   solo lectura.
--
-- MINIMO PRIVILEGIO
--   - SELECT+INSERT sobre MENSAJE y CONVERSACION.
--   - UPDATE por columna SOLO sobre titulo y estado de CONVERSACION
--     (MariaDB 10.4 admite privilegios por columna).
--   - Sin DELETE (las conversaciones se cierran, no se borran) y sin
--     EXECUTE. Las 5 tablas academicas de lectura no cambian.
--
-- SEGURIDAD
--   Este archivo NO contiene contrasenas ni hashes. No crea usuarios.
-- =====================================================================

USE `Kiro`;

-- ---------------------------------------------------------------------
-- 1. Lectura y escritura de mensajes.
-- ---------------------------------------------------------------------
GRANT SELECT, INSERT ON `Kiro`.`MENSAJE`
  TO 'kiro_app'@'127.0.0.1';

-- ---------------------------------------------------------------------
-- 2. Lectura y escritura de conversaciones.
-- ---------------------------------------------------------------------
GRANT SELECT, INSERT ON `Kiro`.`CONVERSACION`
  TO 'kiro_app'@'127.0.0.1';

-- ---------------------------------------------------------------------
-- 3. Solo el titulo y el estado pueden actualizarse de una
--    conversacion ya creada (creacion perezosa: la fila nace con su
--    primer mensaje y luego solo se cierra o se retitula).
-- ---------------------------------------------------------------------
GRANT UPDATE (`titulo`, `estado`) ON `Kiro`.`CONVERSACION`
  TO 'kiro_app'@'127.0.0.1';

-- ---------------------------------------------------------------------
-- Verificacion (solo lectura): deben listarse los 3 GRANT nuevos junto
-- a los existentes (rol_kiro_app, USAGE y SET DEFAULT ROLE).
-- SHOW GRANTS FOR 'kiro_app'@'127.0.0.1';
--
-- NOTA: no se incluye FLUSH PRIVILEGES; los GRANT surten efecto de
-- inmediato y el servidor lo desaconseja de todos modos.
-- ---------------------------------------------------------------------
