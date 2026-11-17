-- =============================================================================
-- KIRO - QUERY_03: DEMOSTRACION DE TRANSACCIONES
--                 (START TRANSACTION, SAVEPOINT, ROLLBACK TO, COMMIT, ROLLBACK)
-- =============================================================================
-- Proyecto:   KIRO (Bases de Datos II)
-- Base:       Kiro - MariaDB 10.4.32 - InnoDB
-- Ejecucion:  mysql.exe -u root --default-character-set=utf8mb4 -t Kiro <
--             QUERY_03_transacciones.sql   (o SOURCE desde el CLI mysql.exe)
--
-- OBJETIVO ACADEMICO
--   Demostrar de forma reproducible, sobre un laboratorio aislado:
--     1. START TRANSACTION y COMMIT: una unidad de trabajo se hace vigente
--        de forma atomica al confirmarla.
--     2. SAVEPOINT y ROLLBACK TO SAVEPOINT: se deshace SOLO lo posterior a
--        un punto intermedio, sin cerrar la transaccion.
--     3. ROLLBACK total: se descarta TODA la transaccion abierta.
--
-- AISLAMIENTO (regla de esta demostracion)
--   Todo ocurre EXCLUSIVAMENTE sobre una tabla TEMPORARY de laboratorio:
--     - Solo existe en la sesion que la crea; otras sesiones no la ven.
--     - No altera la estructura ni los datos de ninguna tabla real de Kiro.
--     - Desaparece automaticamente al cerrar la conexion.
--   El COMMIT conserva el registro VIGENTE DENTRO DE LA SESION; la tabla
--   temporal y su contenido NO sobreviven al cierre de la conexion.
--   Las secciones 0 y 5 son guardias de solo lectura (CHECKSUM y conteos)
--   que demuestran que ninguna tabla real de Kiro cambio.
-- =============================================================================

USE Kiro;

-- =============================================================================
-- SECCION 0: GUARDIAS PREVIAS (solo lectura; baseline de la sesion)
-- =============================================================================
-- Objetivo: registrar el estado de las tablas REALES antes de la demo.
-- Resultado esperado: mismos checksums y conteo que en cualquier momento
-- anterior (la base estable es estable en reposo).
-- =============================================================================
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
-- SECCION 1: TABLA TEMPORAL DE LABORATORIO
-- =============================================================================
-- CREATE/DROP TEMPORARY antes de START TRANSACTION (buena practica: el DDL
-- queda fuera de la unidad de trabajo). ENGINE=InnoDB para usar su soporte
-- transaccional real.
-- =============================================================================
DROP TEMPORARY TABLE IF EXISTS tmp_labo_savepoint;

CREATE TEMPORARY TABLE tmp_labo_savepoint (
    id       INT AUTO_INCREMENT PRIMARY KEY,
    etiqueta VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

-- =============================================================================
-- SECCION 2: ESCENARIO A - SAVEPOINT + ROLLBACK TO SAVEPOINT + COMMIT
-- =============================================================================
-- Paso a paso demostrado:
--   (a) START TRANSACTION: abre la unidad de trabajo.
--   (b) INSERT 1: cambio provisional (visible solo en la transaccion).
--   (c) SAVEPOINT: punto intermedio de control.
--   (d) INSERT 2: segundo cambio provisional.
--   (e) ROLLBACK TO SAVEPOINT: deshace SOLO el INSERT 2; la transaccion
--       sigue abierta (a diferencia de un ROLLBACK total).
--   (f) COMMIT: consolida lo vigente al punto de control.
-- =============================================================================

-- (a) Abrir la transaccion
START TRANSACTION;

-- (b) Primer registro (sera el unico que sobreviva)
INSERT INTO tmp_labo_savepoint (etiqueta) VALUES ('registro_persistente');
SELECT COUNT(*) AS filas_tras_primer_insert FROM tmp_labo_savepoint;

-- (c) Punto de control
SAVEPOINT sp_despues_del_primero;

-- (d) Segundo registro (se descartara)
INSERT INTO tmp_labo_savepoint (etiqueta) VALUES ('registro_a_descartar');
SELECT COUNT(*) AS filas_tras_segundo_insert FROM tmp_labo_savepoint;

-- (e) Deshacer parcial: solo lo posterior al punto
ROLLBACK TO SAVEPOINT sp_despues_del_primero;
SELECT COUNT(*) AS filas_tras_rollback_to FROM tmp_labo_savepoint;

-- (f) Confirmar la transaccion
COMMIT;

-- Resultado final del escenario A: solo permanece 'registro_persistente'.
-- Este registro es vigente DENTRO DE ESTA SESION (tabla temporal).
SELECT id, etiqueta FROM tmp_labo_savepoint;

-- =============================================================================
-- SECCION 3: ESCENARIO B - ROLLBACK TOTAL
-- =============================================================================
-- Complemento: un INSERT dentro de una transaccion que termina en ROLLBACK
-- no deja ningun efecto.
-- =============================================================================
START TRANSACTION;
INSERT INTO tmp_labo_savepoint (etiqueta) VALUES ('registro_de_transaccion_descartada');
SELECT COUNT(*) AS filas_tras_insert_de_b FROM tmp_labo_savepoint;
ROLLBACK;
SELECT COUNT(*) AS filas_tras_rollback_total FROM tmp_labo_savepoint;

-- =============================================================================
-- SECCION 4: ESTADO FINAL DE LA TABLA DE LABORATORIO (dentro de la sesion)
-- =============================================================================
-- Solo el registro del escenario A permanece visible en la sesion. Al cerrar
-- la conexion, la tabla temporal desaparece completa (ver documentacion).
-- =============================================================================
SELECT id, etiqueta FROM tmp_labo_savepoint ORDER BY id;

-- =============================================================================
-- SECCION 5: GUARDIAS POSTERIORES (solo lectura; comparar con SECCION 0)
-- =============================================================================
-- Resultado esperado: checksums y conteo IDENTICOS a la seccion 0 y al
-- baseline historico de la base. Demuestra que la demo no toco tablas reales.
-- =============================================================================
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

-- Fin del script: la tabla temporal tmp_labo_savepoint desaparece cuando
-- termina esta sesion de cliente. No es necesario (ni correcto) hacer DROP
-- de tablas reales; la base Kiro queda exactamente como estaba.
