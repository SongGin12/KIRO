-- =============================================================================
-- KIRO - QUERY_05 - 01b: LECTURA SUCIA - SESION B (nivel READ UNCOMMITTED)
-- =============================================================================
-- Sesion B con READ-UNCOMMITTED. Debe lanzarse SIMULTANEAMENTE con A.
-- Cronologia interna:
--   t ~ 4  : lectura mientras el UPDATE de A esta SIN confirmar.
--            Esperado con READ-UNCOMMITTED: valor 11 (LECTURA SUCIA visible).
--   t ~ 14 : lectura tras el ROLLBACK de A (t ~ 10.5).
--            Esperado: valor 10 y etiqueta 'semilla' (el valor sucio
--            desaparece: nunca fue un dato confirmado).
-- =============================================================================

USE kiro_labo_concurrencia;
SET SESSION tx_isolation = 'READ-UNCOMMITTED';

SELECT CONNECTION_ID() AS conexion_B, NOW(6) AS t_inicio_B, @@session.tx_isolation AS nivel_B;

SELECT SLEEP(4) AS espera_B_primera_lectura;

SELECT NOW(6) AS t_lectura1_B, valor, etiqueta FROM asiento WHERE id = 1;

SELECT SLEEP(10) AS espera_B_segunda_lectura;

SELECT NOW(6) AS t_lectura2_B, valor, etiqueta FROM asiento WHERE id = 1;

SELECT 'FIN_B' AS fin;
