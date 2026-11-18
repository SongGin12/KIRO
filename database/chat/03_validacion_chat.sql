-- =====================================================================
-- KIRO (evolucion chat) - Validacion de solo lectura de la etapa chat
-- Preparado para MariaDB 10.4.32. ETAPA 2 - script 4 de 4.
--
-- OBJETIVO
--   Verificar, SIN MODIFICAR NADA, el resultado de los scripts 1 a 3:
--   indice unico, tablas nuevas, FKs, indice de orden y permisos.
--
-- COMO EJECUTAR
--   Cliente mysql.exe con cuenta administradora:
--     mysql.exe -u root --default-character-set=utf8mb4 < database/chat/03_validacion_chat.sql
--   (o abriendo el archivo en MySQL Workbench). Todo lo que contiene
--   es lectura: SHOW, SELECT sobre information_schema y SHOW GRANTS.
--
-- RESULTADOS ESPERADOS (resumen al final del archivo).
-- =====================================================================

USE `Kiro`;

-- ---------------------------------------------------------------------
-- 1. Estructura de las tablas nuevas (inspeccion visual del DDL).
--    Esperado: InnoDB, utf8mb4_unicode_ci, columnas del diseno.
-- ---------------------------------------------------------------------
SHOW CREATE TABLE `Kiro`.`CONVERSACION`;
SHOW CREATE TABLE `Kiro`.`MENSAJE`;

-- ---------------------------------------------------------------------
-- 2. Indice unico de INICIO_SESION (script 1).
--    Esperado: uk_inicio_sesion_usuario, Non_unique=0,
--    Seq 1 = id_sesion, Seq 2 = id_usuario.
-- ---------------------------------------------------------------------
SHOW INDEX FROM `Kiro`.`INICIO_SESION`;

-- ---------------------------------------------------------------------
-- 3. Indices de CONVERSACION y MENSAJE.
--    Esperado en CONVERSACION: PRIMARY (id_conversacion),
--    ix_conversacion_usuario (id_usuario) y
--    uk_inicio_sesion_usuario reflejado no aplica aqui (es de la tabla padre).
--    Esperado en MENSAJE: PRIMARY (id_mensaje) e
--    ix_mensaje_orden (id_conversacion, fecha_envio, id_mensaje).
-- ---------------------------------------------------------------------
SHOW INDEX FROM `Kiro`.`CONVERSACION`;
SHOW INDEX FROM `Kiro`.`MENSAJE`;

-- ---------------------------------------------------------------------
-- 4. Llaves foraneas nuevas (14 FKs academicas + 3 nuevas = 17 en total).
--    Esperado:
--      fk_conversacion_usuario  -> USUARIO (id_usuario)
--      fk_conversacion_sesion   -> INICIO_SESION (id_sesion, id_usuario)
--      fk_mensaje_conversacion  -> CONVERSACION (id_conversacion)
-- ---------------------------------------------------------------------
SELECT `CONSTRAINT_NAME`   AS `fk`,
       `TABLE_NAME`        AS `tabla`,
       `REFERENCED_TABLE_NAME` AS `referencia`,
       `REFERENCED_COLUMN_NAME` AS `columna_ref`
FROM information_schema.`KEY_COLUMN_USAGE`
WHERE `TABLE_SCHEMA` = 'Kiro'
  AND `REFERENCED_TABLE_NAME` IS NOT NULL
  AND `TABLE_NAME` IN ('CONVERSACION', 'MENSAJE')
ORDER BY `TABLE_NAME`, `CONSTRAINT_NAME`, `ORDINAL_POSITION`;

-- ---------------------------------------------------------------------
-- 5. Comprobacion de la FK compuesta (ambas columnas participan).
-- ---------------------------------------------------------------------
SELECT `CONSTRAINT_NAME`, `COLUMN_NAME`, `ORDINAL_POSITION`
FROM information_schema.`KEY_COLUMN_USAGE`
WHERE `TABLE_SCHEMA` = 'Kiro'
  AND `TABLE_NAME` = 'CONVERSACION'
  AND `CONSTRAINT_NAME` = 'fk_conversacion_sesion'
ORDER BY `ORDINAL_POSITION`;

-- ---------------------------------------------------------------------
-- 6. Charset y collation declarados (informativo).
--    Esperado: utf8mb4 / utf8mb4_unicode_ci en las dos tablas nuevas.
-- ---------------------------------------------------------------------
SELECT `TABLE_NAME`, `ENGINE`, `TABLE_COLLATION`
FROM information_schema.`TABLES`
WHERE `TABLE_SCHEMA` = 'Kiro'
  AND `TABLE_NAME` IN ('CONVERSACION', 'MENSAJE');

-- ---------------------------------------------------------------------
-- 7. Permisos de kiro_app (hash de contrasena NO visible).
--    Esperado ademas de los 3 GRANT existentes:
--      GRANT SELECT, INSERT ON `Kiro`.`MENSAJE` ...
--      GRANT SELECT, INSERT ON `Kiro`.`CONVERSACION` ...
--      GRANT UPDATE (titulo, estado) ON `Kiro`.`CONVERSACION` ...
-- ---------------------------------------------------------------------
SHOW GRANTS FOR 'kiro_app'@'127.0.0.1';

-- ---------------------------------------------------------------------
-- 8. Conteos de datos (solo lectura; la app no ha poblado nada aun).
--    Esperado en esta etapa: 0 filas en ambas tablas. Los mensajes de
--    prueba NO se insertan con SQL manual: se enviaran desde la
--    interfaz y el backend los guardara automaticamente.
-- ---------------------------------------------------------------------
SELECT 'CONVERSACION' AS `tabla`, COUNT(*) AS `filas` FROM `Kiro`.`CONVERSACION`
UNION ALL
SELECT 'MENSAJE', COUNT(*) FROM `Kiro`.`MENSAJE`;

-- ---------------------------------------------------------------------
-- RESULTADOS ESPERADOS (criterio de aceptacion de esta validacion)
--   1. SHOW CREATE: ambas tablas InnoDB, utf8mb4_unicode_ci, sin
--      atributos derivados.
--   2. uk_inicio_sesion_usuario existe y es unico (Non_unique=0).
--   3. ix_mensaje_orden con las 3 columnas en orden correcto.
--   4. Las 3 FKs nuevas listadas; el total de FKs del esquema pasa de
--      14 (academico) a 17.
--   5. fk_conversacion_sesion con 2 columnas (id_sesion, id_usuario).
--   6. Collations correctos.
--   7. Los 3 GRANT nuevos presentes; sin DELETE ni EXECUTE.
--   8. 0 filas en ambas tablas.
-- ---------------------------------------------------------------------
