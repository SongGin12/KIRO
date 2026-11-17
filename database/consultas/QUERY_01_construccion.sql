-- =============================================================================
-- KIRO - QUERY_01: GUIA DE CONSTRUCCION DE LA BASE DE DATOS (ORQUESTADOR)
-- =============================================================================
-- Proyecto:  KIRO (Bases de Datos II)
-- Base:      Kiro - MariaDB 10.4.32 - InnoDB - utf8mb4_unicode_ci
-- Rol de este archivo: ORQUESTADOR. No contiene el DDL ni los INSERT: solo
--   ordena la ejecucion de los scripts reales y explica que hace cada uno.
--   La UNICA fuente de verdad de la construccion es:
--     - database/KIRO_MariaDB.sql     (esquema + datos semilla)
--     - database/objetos/01..05       (vistas, funciones, SP, triggers, permisos)
--   Si este orquestador y esos archivos se desincronizaran, mandan esos archivos.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. PREREQUISITOS ANTES DE EMPEZAR
-- -----------------------------------------------------------------------------
-- 1) Conectar con una cuenta ADMINISTRADORA (por ejemplo root local).
--    Razón: los objetos de database/objetos/ conservan el DEFINER original
--    (root@localhost) y un usuario limitado no puede crearlos.
-- 2) Entorno confirmado: MariaDB 10.4.32 (comprobar con SELECT VERSION()).
--    En MariaDB sobre Windows aplica lower_case_table_names=1, por lo que los
--    nombres Kiro / kiro resuelven igual; en Linux seria sensible a mayusculas.
-- 3) IMPORTANTE - COMPATIBILIDAD DE "SOURCE":
--    SOURCE es un comando del CLIENTE mysql.exe (CLI). NO funciona en:
--      - MySQL Workbench (editor SQL),
--      - PHP/PDO ni en clientes generales de MySQL.
--    Si se ejecuta en uno de esos entornos, NO usar este orquestador como
--    script automatico: abrir y ejecutar, en este mismo orden, cada archivo
--    listado abajo. Este archivo sigue siendo valido como GUIA DOCUMENTADA
--    del orden de construccion.

-- -----------------------------------------------------------------------------
-- 1. ORDEN DE EJECUCION DESDE UNA BASE VACIA (tabla resumen)
-- -----------------------------------------------------------------------------
-- Paso | Archivo                              | Que crea
-- -----+--------------------------------------+--------------------------------
--   1  | ../KIRO_MariaDB.sql                  | Base Kiro, 12 tablas, 12 PK,
--      |                                      | 14 FK (3 compuestas), 19 indices
--      |                                      | secundarios y 120 registros
--      |                                      | semilla (10 por tabla).
--   2  | ../objetos/01_vistas.sql             | 4 vistas.
--   3  | ../objetos/02_funciones.sql          | 5 funciones almacenadas.
--   4  | ../objetos/03_procedimientos.sql     | 2 SP (1 transaccional, 1 cursor).
--   5  | ../objetos/04_triggers.sql           | 2 triggers (validacion y
--      |                                      | auditoria hacia HISTORIAL_ACCION).
--   6  | ../objetos/05_permisos.sql           | Rol rol_kiro_app (SELECT en 5
--      |                                      | tablas) y usuario kiro_app
--      |                                      | (Paso 2 MANUAL: la contrasena la
--      |                                      | elige el instalador; nunca se
--      |                                      | registra en el repositorio).
-- -----------------------------------------------------------------------------
-- Por ese orden: las FKs solo pueden crearse cuando las tablas padre existen
-- (paso 1); las vistas consultan tablas (despues del paso 1); las funciones y
-- SP consultan tablas y vistas; el trigger de auditoria escribe en
-- HISTORIAL_ACCION; los permisos van al final para que el rol de aplicacion
-- tenga a quien aplicarse.
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- 2. EJECUCION (solo cliente mysql.exe CLI; rutas relativas a esta carpeta)
-- -----------------------------------------------------------------------------
-- Se usan separadores "/" (aceptados por mysql en Windows y Linux).

-- Paso 1: esquema completo + datos semilla (120 registros).
-- SOURCE ../KIRO_MariaDB.sql;

-- Paso 2: vistas.
-- SOURCE ../objetos/01_vistas.sql;

-- Paso 3: funciones.
-- SOURCE ../objetos/02_funciones.sql;

-- Paso 4: procedimientos almacenados.
-- SOURCE ../objetos/03_procedimientos.sql;

-- Paso 5: triggers.
-- SOURCE ../objetos/04_triggers.sql;

-- Paso 6: rol y usuario de la aplicacion (ver el Paso 2 manual dentro del
-- archivo: el CREATE USER queda comentado y sin contrasenas a proposito).
-- SOURCE ../objetos/05_permisos.sql;

-- -----------------------------------------------------------------------------
-- 3. VERIFICACION FINAL DE LA CONSTRUCCION (solo lectura)
-- -----------------------------------------------------------------------------
-- Esperado tras una construccion completa desde cero:
--   tablas = 12, vistas = 4, funciones = 5, SP = 2, triggers = 2, indices = 19
--   registros semilla = 120 (10 por tabla). Si ya se ejecutaron las pruebas
--   del laboratorio, CITA e HISTORIAL_ACCION suman 1 registro cada una
--   (11 y 11): 122 en total. Ver docs/evidencias/01_tablas_conteos.md.

-- 3.1 Objetos existentes por tipo.
SELECT 'tablas' AS objeto, COUNT(*) AS total
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'Kiro' AND TABLE_TYPE = 'BASE TABLE'
UNION ALL
SELECT 'vistas', COUNT(*) FROM information_schema.VIEWS WHERE TABLE_SCHEMA = 'Kiro'
UNION ALL
SELECT 'funciones', COUNT(*) FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'Kiro' AND ROUTINE_TYPE = 'FUNCTION'
UNION ALL
SELECT 'procedimientos', COUNT(*) FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'Kiro' AND ROUTINE_TYPE = 'PROCEDURE'
UNION ALL
SELECT 'triggers', COUNT(*) FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA = 'Kiro';

-- 3.2 Registros semilla por tabla (120 esperados: 10 por tabla).
SELECT 'USUARIO' AS tabla, COUNT(*) AS registros FROM Kiro.USUARIO
UNION ALL SELECT 'REGISTRO_USUARIO', COUNT(*) FROM Kiro.REGISTRO_USUARIO
UNION ALL SELECT 'PERFIL_KIRO',      COUNT(*) FROM Kiro.PERFIL_KIRO
UNION ALL SELECT 'INICIO_SESION',    COUNT(*) FROM Kiro.INICIO_SESION
UNION ALL SELECT 'CATEGORIA',        COUNT(*) FROM Kiro.CATEGORIA
UNION ALL SELECT 'PROYECTO',         COUNT(*) FROM Kiro.PROYECTO
UNION ALL SELECT 'NOTA',             COUNT(*) FROM Kiro.NOTA
UNION ALL SELECT 'RECURSO',          COUNT(*) FROM Kiro.RECURSO
UNION ALL SELECT 'ACTIVIDAD',        COUNT(*) FROM Kiro.ACTIVIDAD
UNION ALL SELECT 'CITA',             COUNT(*) FROM Kiro.CITA
UNION ALL SELECT 'RECUERDO',         COUNT(*) FROM Kiro.RECUERDO
UNION ALL SELECT 'HISTORIAL_ACCION', COUNT(*) FROM Kiro.HISTORIAL_ACCION;

-- -----------------------------------------------------------------------------
-- FIN DE QUERY_01: la base queda construida y verificada.
-- Siguiente paso: database/consultas/QUERY_02_consultas.sql (solo lectura).
-- -----------------------------------------------------------------------------
