-- =============================================================================
-- KIRO - QUERY_05 - 03: BLOQUEO DE FILA - SESION A (retiene y confirma)
-- =============================================================================
-- Sesion A. Debe lanzarse SIMULTANEAMENTE con 03_bloqueo_B.
-- Cronologia interna:
--   t ~ 0.3: abre transaccion y ACTUALIZA la fila (10 -> 11): InnoDB toma un
--            bloqueo exclusivo (X) sobre esa fila.
--   t ~ 10.3: COMMIT: libera el bloqueo. A partir de ese instante, el UPDATE
--            pendiente de B puede avanzar.
-- La fila queda en 11 tras el COMMIT de A; B le sumara 10 (resultado final
-- esperado: 21).
-- =============================================================================
USE kiro_labo_concurrencia;
SET SESSION tx_isolation = 'REPEATABLE-READ';

SELECT CONNECTION_ID() AS conexion_A, NOW(6) AS t_inicio_A, @@session.tx_isolation AS nivel_A;

START TRANSACTION;

UPDATE asiento SET valor = valor + 1, etiqueta = 'A_bloqueo' WHERE id = 1;
SELECT NOW(6) AS t_update_A, valor, etiqueta FROM asiento WHERE id = 1;

SELECT SLEEP(10) AS retiene_bloqueo_de_fila;

COMMIT;
SELECT NOW(6) AS t_commit_A;

SELECT 'FIN_A' AS fin;
