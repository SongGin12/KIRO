-- =============================================================================
-- KIRO - QUERY_05 - 01a: LECTURA SUCIA - SESION B (prevencion con REPEATABLE READ)
-- =============================================================================
-- Sesion B (conexion independiente). Debe lanzarse SIMULTANEAMENTE con la
-- sesion A. Cronologia interna:
--   t ~ 4  : PRIMERA lectura, mientras A mantiene su UPDATE sin confirmar.
--            Esperado con REPEATABLE READ: valor 10 (NO ve la lectura sucia).
--   t ~ 16 : SEGUNDA lectura, tras el ROLLBACK de A.
--            Esperado: valor 10 (semilla).
-- Resultado esperado del experimento: 10 en ambas lecturas (prevencion).
-- =============================================================================

USE kiro_labo_concurrencia;
SET SESSION tx_isolation = 'REPEATABLE-READ';

SELECT CONNECTION_ID() AS conexion_B, NOW(6) AS t_inicio_B, @@session.tx_isolation AS nivel_B;

SELECT SLEEP(4) AS espera_B_primera_lectura;

SELECT NOW(6) AS t_lectura1_B, valor, etiqueta FROM asiento WHERE id = 1;

SELECT SLEEP(12) AS espera_B_segunda_lectura;

SELECT NOW(6) AS t_lectura2_B, valor, etiqueta FROM asiento WHERE id = 1;

SELECT 'FIN_B' AS fin;
