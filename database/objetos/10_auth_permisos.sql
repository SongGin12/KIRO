-- =====================================================================
-- KIRO - Matriz de privilegios de autenticacion
-- MariaDB 10.4.32 · script 10 (4 de 5)
--
-- QUE HACE
--   Ajusta rol_kiro_app (la cuenta de la aplicacion) y concede los
--   privilegios minimos a las 4 cuentas tecnicas nuevas.
--
-- ANTES DE EJECUTAR
--   07_auth_tablas.sql, 08_auth_cuentas.sql y 09_auth_procedimientos.sql
--   (GRANT ... ON PROCEDURE exige que el procedimiento exista).
--
-- NOTA SOBRE REPETICION
--   Los GRANT son idempotentes. El REVOKE de la linea 1 solo se ejecuta
--   una vez; si se repite, MariaDB responde 1141 (no existe ese grant)
--   y no altera nada. Es seguro continuar.
--
-- MODELO
--   kiro_app        aplicacion web (rol_kiro_app)
--   kiro_auth       solo credenciales de login
--   kiro_admin      panel administrativo (sin datos privados)
--   kiro_activador  solo EXECUTE del SP de activacion
--   kiro_sp_definer dueno de los SP (cuenta bloqueada, no es conexion)
--
-- SEGURIDAD
--   Ninguna cuenta de aplicacion recibe INSERT/UPDATE/DELETE sobre
--   NOTA, RECUERDO, CITA, PROYECTO, ACTIVIDAD, RECURSO ni CATEGORIA.
-- =====================================================================

USE `Kiro`;

-- ---------------------------------------------------------------------
-- 1. Cuenta de la aplicacion (rol_kiro_app)
--    Se retira el SELECT de tabla completa sobre USUARIO (exponia
--    hash_contrasena) y se sustituye por columnas concretas.
-- ---------------------------------------------------------------------
REVOKE SELECT ON `Kiro`.`usuario` FROM 'rol_kiro_app';

GRANT SELECT (`id_usuario`, `nombre`, `correo`, `fecha_registro`)
    ON `Kiro`.`usuario` TO 'rol_kiro_app';

GRANT INSERT (`nombre`, `correo`, `fecha_registro`, `hash_contrasena`)
    ON `Kiro`.`usuario` TO 'rol_kiro_app';

GRANT INSERT (`nombre_companero`, `personalidad`, `estilo_comunicacion`,
              `color_principal`, `memoria_activa`, `id_usuario`)
    ON `Kiro`.`perfil_kiro` TO 'rol_kiro_app';

GRANT INSERT (`metodo_registro`, `estado_verificacion`,
              `fecha_verificacion`, `id_usuario`)
    ON `Kiro`.`registro_usuario` TO 'rol_kiro_app';

GRANT INSERT (`fecha_inicio`, `fecha_fin`, `estado_sesion`, `id_usuario`)
    ON `Kiro`.`inicio_sesion` TO 'rol_kiro_app';

GRANT UPDATE (`fecha_fin`, `estado_sesion`)
    ON `Kiro`.`inicio_sesion` TO 'rol_kiro_app';

-- ---------------------------------------------------------------------
-- 2. kiro_auth: solo lo imprescindible para verificar la contrasena.
-- ---------------------------------------------------------------------
GRANT SELECT (`id_usuario`, `correo`, `hash_contrasena`)
    ON `Kiro`.`usuario` TO 'kiro_auth'@'127.0.0.1';

-- ---------------------------------------------------------------------
-- 3. kiro_admin: leer usuarios sin datos privados y auditar sus acciones.
-- ---------------------------------------------------------------------
GRANT SELECT (`id_usuario`, `nombre`, `correo`, `fecha_registro`)
    ON `Kiro`.`usuario` TO 'kiro_admin'@'127.0.0.1';

GRANT SELECT (`id_admin`, `nombre`, `correo`, `hash_contrasena_admin`,
               `activo`, `fecha_alta`, `ultimo_acceso`)
    ON `Kiro`.`administrador` TO 'kiro_admin'@'127.0.0.1';

GRANT UPDATE (`ultimo_acceso`)
    ON `Kiro`.`administrador` TO 'kiro_admin'@'127.0.0.1';

GRANT SELECT, INSERT ON `Kiro`.`accion_admin` TO 'kiro_admin'@'127.0.0.1';

GRANT EXECUTE ON PROCEDURE `Kiro`.`sp_emitir_codigo_activacion`
    TO 'kiro_admin'@'127.0.0.1';

-- ---------------------------------------------------------------------
-- 4. kiro_activador: CERO privilegios de tabla. Solo ejecuta el SP.
-- ---------------------------------------------------------------------
GRANT EXECUTE ON PROCEDURE `Kiro`.`sp_activar_credencial`
    TO 'kiro_activador'@'127.0.0.1';

-- ---------------------------------------------------------------------
-- 5. kiro_sp_definer: privilegios que necesitan los SP al ejecutarse.
--    Son por columna donde es posible. No tiene DELETE ni DDL.
-- ---------------------------------------------------------------------
GRANT SELECT (`id_usuario`, `correo`, `hash_contrasena`)
    ON `Kiro`.`usuario` TO 'kiro_sp_definer'@'127.0.0.1';
GRANT UPDATE (`hash_contrasena`)
    ON `Kiro`.`usuario` TO 'kiro_sp_definer'@'127.0.0.1';

GRANT SELECT (`id_admin`, `activo`)
    ON `Kiro`.`administrador` TO 'kiro_sp_definer'@'127.0.0.1';

GRANT SELECT, INSERT, UPDATE ON `Kiro`.`codigo_activacion`
    TO 'kiro_sp_definer'@'127.0.0.1';

GRANT INSERT ON `Kiro`.`historial_accion`
    TO 'kiro_sp_definer'@'127.0.0.1';

GRANT INSERT ON `Kiro`.`accion_admin`
    TO 'kiro_sp_definer'@'127.0.0.1';

-- MariaDB exige EXECUTE tambien al DEFINER de un procedimiento con
-- SQL SECURITY DEFINER. Sin estas dos lineas el SP falla con 1370.
GRANT EXECUTE ON PROCEDURE `Kiro`.`sp_emitir_codigo_activacion`
    TO 'kiro_sp_definer'@'127.0.0.1';
GRANT EXECUTE ON PROCEDURE `Kiro`.`sp_activar_credencial`
    TO 'kiro_sp_definer'@'127.0.0.1';
