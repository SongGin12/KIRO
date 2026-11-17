-- =============================================================================
-- KIRO - QUERY_05 - 02b: LECTURA NO REPETIBLE - SESION B (REPEATABLE READ)
-- =============================================================================
-- Identica a 02a pero con REPEATABLE-READ (nivel por defecto del servidor).
-- Debe lanzarse SIMULTANEAMENTE con 02_A (y con la fila restaurada a 10).
-- Cronologia interna:
--   t ~ 0.3: abre transaccion y PRIMERA lectura. Esperado: 10.
--   t ~ 5.5: A confirma el cambio a 20.
--   t ~ 15.5: SEGUNDA lectura. Esperado con REPEATABLE-READ: 10
--            (snapshot consistente de la transaccion: la misma consulta
--            devuelve el MISMO valor; lectura no repetible prevenida).
-- =============================================================================
USE kiro_labo_concurrencia;
SET SESSION tx_isolation = 'REPEATABLE-READ';

SELECT CONNECTION_ID() AS conexion_B, NOW(6) AS t_inicio_B, @@session.tx_isolation AS nivel_B;

START TRANSACTION;

SELECT NOW(6) AS t_lectura1_B, valor, etiqueta FROM asiento WHERE id = 1;

SELECT SLEEP(15) AS espera_B_segunda_lectura;

SELECT NOW(6) AS t_lectura2_B, valor, etiqueta FROM asiento WHERE id = 1;

COMMIT;
SELECT NOW(6) AS t_commit_B;

SELECT 'FIN_B' AS fin;
