-- =============================================================================
-- KIRO - QUERY_05 - 02a: LECTURA NO REPETIBLE - SESION B (READ COMMITTED)
-- =============================================================================
-- Sesion B con READ-COMMITTED. Debe lanzarse SIMULTANEAMENTE con 02_A.
-- Cronologia interna:
--   t ~ 0.3: abre transaccion y PRIMERA lectura. Esperado: 10.
--   t ~ 5.5: A confirma el cambio a 20 (COMMIT durante esta transaccion).
--   t ~ 15.5: SEGUNDA lectura. Esperado con READ-COMMITTED: 20
--            (LECTURA NO REPETIBLE: la misma consulta devuelve otro valor
--            dentro de una misma transaccion).
--   COMMIT: cierra la transaccion explicitamente.
-- =============================================================================
USE kiro_labo_concurrencia;
SET SESSION tx_isolation = 'READ-COMMITTED';

SELECT CONNECTION_ID() AS conexion_B, NOW(6) AS t_inicio_B, @@session.tx_isolation AS nivel_B;

START TRANSACTION;

SELECT NOW(6) AS t_lectura1_B, valor, etiqueta FROM asiento WHERE id = 1;

SELECT SLEEP(15) AS espera_B_segunda_lectura;

SELECT NOW(6) AS t_lectura2_B, valor, etiqueta FROM asiento WHERE id = 1;

COMMIT;
SELECT NOW(6) AS t_commit_B;

SELECT 'FIN_B' AS fin;
