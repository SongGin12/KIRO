-- =============================================================================
-- KIRO - QUERY_05 - 02: LECTURA NO REPETIBLE - SESION A (comun a 2a y 2b)
-- =============================================================================
-- Sesion A. Debe lanzarse SIMULTANEAMENTE con la sesion B del experimento
-- (02a_B_READ_COMMITTED o 02b_B_REPEATABLE_READ).
-- Cronologia interna:
--   t ~ 0  : inicio (B ya abrio su transaccion y leyo 10 en t ~ 0.3).
--   t ~ 5  : abre transaccion, ACTUALIZA la fila a 20 y CONFIRMA.
-- El COMMIT de A ocurre MIENTRAS la transaccion de B sigue abierta: ese es
-- el momento que produce (o previene) la lectura no repetible en B.
-- =============================================================================
USE kiro_labo_concurrencia;
SET SESSION tx_isolation = 'REPEATABLE-READ';

SELECT CONNECTION_ID() AS conexion_A, NOW(6) AS t_inicio_A, @@session.tx_isolation AS nivel_A;

SELECT SLEEP(5) AS espera_A_para_dejar_leer_a_B;

START TRANSACTION;

UPDATE asiento SET valor = 20, etiqueta = 'A_confirmada' WHERE id = 1;
COMMIT;

SELECT NOW(6) AS t_commit_A, valor, etiqueta FROM asiento WHERE id = 1;

SELECT 'FIN_A' AS fin;
