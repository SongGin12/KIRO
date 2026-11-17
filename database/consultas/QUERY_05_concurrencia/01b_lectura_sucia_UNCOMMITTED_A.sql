-- =============================================================================
-- KIRO - QUERY_05 - 01b: LECTURA SUCIA - SESION A (nivel REPEATABLE READ)
-- =============================================================================
-- Identica en conducta a 01a_A: actualiza SIN confirmar y hace ROLLBACK en
-- t ~ 10.5. Acompaña a la sesion B de READ-UNCOMMITTED (01b_B), que DEBE ver
-- el valor no confirmado (11): la lectura sucia existe y el nivel de
-- aislamiento es lo que la permite o la previene.
-- =============================================================================

USE kiro_labo_concurrencia;
SET SESSION tx_isolation = 'REPEATABLE-READ';

SELECT CONNECTION_ID() AS conexion_A, NOW(6) AS t_inicio_A, @@session.tx_isolation AS nivel_A;

START TRANSACTION;

UPDATE asiento SET valor = 11, etiqueta = 'A_sin_confirmar' WHERE id = 1;
SELECT NOW(6) AS t_update_A, valor, etiqueta FROM asiento WHERE id = 1;

SELECT SLEEP(10) AS pausa_A_con_cambio_sin_confirmar;

ROLLBACK;
SELECT NOW(6) AS t_rollback_A, valor, etiqueta FROM asiento WHERE id = 1;

SELECT 'FIN_A' AS fin;
