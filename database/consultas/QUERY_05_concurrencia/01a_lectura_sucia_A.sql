-- =============================================================================
-- KIRO - QUERY_05 - 01a: LECTURA SUCIA - SESION A (prevencion con REPEATABLE READ)
-- =============================================================================
-- Sesion A (conexion independiente). Cronologia interna:
--   t ~ 0.0 : inicio, abre transaccion y ACTUALIZA la fila SIN confirmar.
--   t ~ 0.5 : se ve su propio cambio (11) dentro de la transaccion.
--   t ~ 12.5: ROLLBACK (descarta el cambio).
--   t ~ 12.6: verifica que la fila volvio a 10.
-- La sesion B (01a_lectura_sucia_B.sql) debe lanzarse SIMULTANEAMENTE: lee en
-- t ~ 4 (con el cambio de A sin confirmar en vuelo) y en t ~ 16 (tras el
-- ROLLBACK). Las marcas NOW(6) permiten reconstruir el orden real.
-- =============================================================================

USE kiro_labo_concurrencia;
SET SESSION tx_isolation = 'REPEATABLE-READ';

SELECT CONNECTION_ID() AS conexion_A, NOW(6) AS t_inicio_A, @@session.tx_isolation AS nivel_A;

START TRANSACTION;

UPDATE asiento SET valor = 11, etiqueta = 'A_sin_confirmar' WHERE id = 1;
SELECT NOW(6) AS t_update_A, valor, etiqueta FROM asiento WHERE id = 1;

SELECT SLEEP(12) AS pausa_A_con_cambio_sin_confirmar;

ROLLBACK;
SELECT NOW(6) AS t_rollback_A, valor, etiqueta FROM asiento WHERE id = 1;

SELECT 'FIN_A' AS fin;
