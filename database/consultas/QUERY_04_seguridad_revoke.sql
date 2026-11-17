-- =============================================================================
-- KIRO - QUERY_04: DEMOSTRACION DE REVOKE CON UN ROL DE LABORATORIO
-- =============================================================================
-- Proyecto:   KIRO (Bases de Datos II)
-- Base:       Kiro - MariaDB 10.4.32
-- Ejecucion:  mysql.exe -u root --default-character-set=utf8mb4 -t Kiro <
--             QUERY_04_seguridad_revoke.sql  (o SOURCE desde el CLI mysql.exe)
--
-- OBJETIVO ACADEMICO
--   Demostrar el ciclo completo de concesion y retirada de un privilegio:
--     1. GRANT SELECT sobre una tabla al rol de laboratorio.
--     2. SHOW GRANTS: el permiso concedido es observable.
--     3. REVOKE SELECT FROM: el permiso se retira.
--     4. SHOW GRANTS: el permiso ya no aparece (solo USAGE).
--   y comprobar que los permisos reales de KIRO (rol rol_kiro_app y usuario
--   kiro_app) quedan intactos durante toda la prueba.
--
-- AISLAMIENTO (reglas de esta demostracion)
--   - Se usa EXCLUSIVAMENTE el rol de laboratorio rol_labo_revoke.
--   - NO se crea ningun usuario de laboratorio y NO se generan contrasenas.
--   - NO se provoca ningun error intencional: la retirada se demuestra con
--     SHOW GRANTS (catalogo), no con intentos de acceso fallidos.
--   - kiro_app y rol_kiro_app no aparecen en ninguna sentencia de cambio;
--     solo se consultan con SHOW GRANTS como baseline (paso 0 y paso 9).
--   - GRANT y REVOKE modifican unicamente metadatos de privilegios del
--     servidor (tablas del sistema), nunca datos del esquema Kiro.
--   - El rol de laboratorio se elimina al final; la seccion 8 verifica su
--     ausencia en el catalogo (sin errores, por conteo).
-- =============================================================================

USE Kiro;

-- =============================================================================
-- SECCION 0: GUARDIAS PREVIAS (solo lectura)
-- =============================================================================
-- Baseline de los permisos reales de KIRO y del contenido de la base.
-- Resultado esperado: 5 GRANT SELECT + USAGE en el rol; rol asignado,
-- USAGE y DEFAULT ROLE en el usuario; checksums y conteo identicos al
-- baseline historico (122 registros).
-- =============================================================================
SHOW GRANTS FOR rol_kiro_app;
SHOW GRANTS FOR kiro_app@127.0.0.1;

CHECKSUM TABLE
    USUARIO, REGISTRO_USUARIO, PERFIL_KIRO, INICIO_SESION, CATEGORIA,
    PROYECTO, NOTA, RECURSO, ACTIVIDAD, CITA, RECUERDO, HISTORIAL_ACCION;

SELECT
    (SELECT COUNT(*) FROM USUARIO)
  + (SELECT COUNT(*) FROM REGISTRO_USUARIO)
  + (SELECT COUNT(*) FROM PERFIL_KIRO)
  + (SELECT COUNT(*) FROM INICIO_SESION)
  + (SELECT COUNT(*) FROM CATEGORIA)
  + (SELECT COUNT(*) FROM PROYECTO)
  + (SELECT COUNT(*) FROM NOTA)
  + (SELECT COUNT(*) FROM RECURSO)
  + (SELECT COUNT(*) FROM ACTIVIDAD)
  + (SELECT COUNT(*) FROM CITA)
  + (SELECT COUNT(*) FROM RECUERDO)
  + (SELECT COUNT(*) FROM HISTORIAL_ACCION)
  AS total_registros_tablas_reales;

-- =============================================================================
-- SECCION 1: CREAR EL ROL DE LABORATORIO
-- =============================================================================
-- El guard de existencia se ejecuto antes de este script (conteo en
-- mysql.user = 0). Si el rol existiera, el proceso debe detenerse antes
-- de llegar aqui, sin eliminar nada automaticamente.
-- =============================================================================
CREATE ROLE IF NOT EXISTS rol_labo_revoke;

-- =============================================================================
-- SECCION 2: CONCEDER EL PERMISO DE PRUEBA
-- =============================================================================
-- GRANT SELECT (solo lectura) sobre la tabla CITA al rol de laboratorio.
-- Escogemos CITA porque es una de las tablas que la aplicacion realmente
-- consulta: el ejemplo es representativo del esquema de permisos de KIRO.
-- =============================================================================
GRANT SELECT ON `Kiro`.`CITA` TO rol_labo_revoke;

-- =============================================================================
-- SECCION 3: COMPROBAR EL PERMISO CONCEDIDO (SHOW GRANTS)
-- =============================================================================
-- Resultado esperado: USAGE global + GRANT SELECT ON kiro.cita.
-- =============================================================================
SHOW GRANTS FOR rol_labo_revoke;

-- =============================================================================
-- SECCION 4: REVOKE
-- =============================================================================
-- Retirada del privilegio concedido en la seccion 2.
-- =============================================================================
REVOKE SELECT ON `Kiro`.`CITA` FROM rol_labo_revoke;

-- =============================================================================
-- SECCION 5: COMPROBAR LA RETIRADA (SHOW GRANTS)
-- =============================================================================
-- Resultado esperado: solo USAGE global; el SELECT sobre CITA desaparecio.
-- =============================================================================
SHOW GRANTS FOR rol_labo_revoke;

-- =============================================================================
-- SECCION 6: ELIMINAR EL ROL DE LABORATORIO
-- =============================================================================
-- Al eliminar el rol, MariaDB retira sus privilegios y sus asignaciones.
-- =============================================================================
DROP ROLE rol_labo_revoke;

-- =============================================================================
-- SECCION 7: VERIFICAR LA AUSENCIA DEL ROL (por conteo, sin errores)
-- =============================================================================
-- Resultado esperado: 0 en ambas consultas del catalogo.
-- =============================================================================
SELECT COUNT(*) AS restos_en_mysql_user
FROM mysql.user WHERE User = 'rol_labo_revoke';

SELECT COUNT(*) AS restos_en_roles_mapping
FROM mysql.roles_mapping WHERE Role = 'rol_labo_revoke';

-- =============================================================================
-- SECCION 8: GUARDIAS POSTERIORES (comparar con la SECCION 0)
-- =============================================================================
-- Resultado esperado: SHOW GRANTS de kiro_app y rol_kiro_app IDENTICOS al
-- paso 0; checksums y conteo identicos al baseline historico.
-- =============================================================================
SHOW GRANTS FOR rol_kiro_app;
SHOW GRANTS FOR kiro_app@127.0.0.1;

CHECKSUM TABLE
    USUARIO, REGISTRO_USUARIO, PERFIL_KIRO, INICIO_SESION, CATEGORIA,
    PROYECTO, NOTA, RECURSO, ACTIVIDAD, CITA, RECUERDO, HISTORIAL_ACCION;

SELECT
    (SELECT COUNT(*) FROM USUARIO)
  + (SELECT COUNT(*) FROM REGISTRO_USUARIO)
  + (SELECT COUNT(*) FROM PERFIL_KIRO)
  + (SELECT COUNT(*) FROM INICIO_SESION)
  + (SELECT COUNT(*) FROM CATEGORIA)
  + (SELECT COUNT(*) FROM PROYECTO)
  + (SELECT COUNT(*) FROM NOTA)
  + (SELECT COUNT(*) FROM RECURSO)
  + (SELECT COUNT(*) FROM ACTIVIDAD)
  + (SELECT COUNT(*) FROM CITA)
  + (SELECT COUNT(*) FROM RECUERDO)
  + (SELECT COUNT(*) FROM HISTORIAL_ACCION)
  AS total_registros_tablas_reales;

-- Fin del script: ningun objeto de laboratorio debe quedar en el servidor.
