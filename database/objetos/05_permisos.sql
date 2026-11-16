-- =====================================================================
-- KIRO - Roles y permisos de la aplicacion (1 rol, 1 usuario)
-- Exportado/desarrollado para MariaDB 10.4.32 el 2026-11-15.
--
-- OBJETIVO
--   Reproducir el principio de minimo privilegio de la aplicacion KIRO:
--   el backend PHP solo necesita LEER las cinco tablas que consulta.
--
-- ADVERTENCIA
--   Ejecutar este archivo SOLO con una cuenta administradora (por
--   ejemplo root local). Declara un rol y concede privilegios.
--
-- CONTENIDO
--   1. Rol `rol_kiro_app` con SELECT sobre las 5 tablas que usa la app.
--   2. Usuario `kiro_app`@`127.0.0.1` (crear manualmente, ver Paso 2).
--   3. Asignacion del rol al usuario y rol predeterminado.
--   4. Verificacion con SHOW GRANTS.
--
-- NOTA
--   El nombre del esquema se escribe `Kiro`, igual que en el DDL
--   canonico database/KIRO_MariaDB.sql. En MariaDB sobre Windows los
--   nombres resuelven sin distinguir mayusculas (lower_case_table_names=1).
--
-- SEGURIDAD
--   Este archivo NO contiene contrasenas ni hashes. La contrasena del
--   usuario la elige el instalador localmente (Paso 2) y no debe
--   registrarse nunca en el repositorio.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Paso 1. Rol de aplicacion: solo lectura de las tablas que consulta la
-- aplicacion (USUARIO, PERFIL_KIRO, CITA, ACTIVIDAD, PROYECTO).
-- No se conceden INSERT, UPDATE, DELETE, CREATE, EXECUTE ni otros
-- privilegios: la etapa actual de KIRO es de solo lectura.
-- ---------------------------------------------------------------------
CREATE ROLE IF NOT EXISTS `rol_kiro_app`;

GRANT SELECT ON `Kiro`.`USUARIO`     TO `rol_kiro_app`;
GRANT SELECT ON `Kiro`.`PERFIL_KIRO` TO `rol_kiro_app`;
GRANT SELECT ON `Kiro`.`CITA`        TO `rol_kiro_app`;
GRANT SELECT ON `Kiro`.`ACTIVIDAD`   TO `rol_kiro_app`;
GRANT SELECT ON `Kiro`.`PROYECTO`    TO `rol_kiro_app`;

-- ---------------------------------------------------------------------
-- Paso 2. Usuario de aplicacion (EJECUTAR MANUALMENTE).
--
-- La contrasena la elige el instalador y NUNCA se registra en el
-- repositorio. Por eso el CREATE USER queda comentado: descomentarlo,
-- reemplazar el marcador <ELEGIR_CONTRASENA_AQUI> por la contrasena
-- elegida y ejecutar la linea una sola vez.
--
-- CREATE USER IF NOT EXISTS 'kiro_app'@'127.0.0.1'
--   IDENTIFIED BY '<ELEGIR_CONTRASENA_AQUI>';
--
-- Recomendaciones: contrasena larga y unica, no reutilizada de otras
-- cuentas; anotarla en un gestor de contrasenas, no en el proyecto.
-- ---------------------------------------------------------------------

-- ---------------------------------------------------------------------
-- Paso 3. Asignacion del rol al usuario y rol predeterminado.
-- (Requiere que el usuario exista: ejecutar el Paso 2 antes.)
-- El rol predeterminado hace que las conexiones de la aplicacion
-- activen automaticamente los permisos del rol al conectarse.
-- ---------------------------------------------------------------------
GRANT `rol_kiro_app` TO 'kiro_app'@'127.0.0.1';

SET DEFAULT ROLE `rol_kiro_app` FOR 'kiro_app'@'127.0.0.1';

-- ---------------------------------------------------------------------
-- Paso 4. Verificacion (solo lectura, sin riesgo).
-- La primera linea debe mostrar el rol asignado; la segunda, los cinco
-- GRANT SELECT del rol. Ninguna salida debe mostrar contrasenas.
-- ---------------------------------------------------------------------
SHOW GRANTS FOR 'kiro_app'@'127.0.0.1';
SHOW GRANTS FOR `rol_kiro_app`;
