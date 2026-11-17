-- =============================================================================
-- KIRO - QUERY_05 - 03: BLOQUEO DE FILA - SESION B (espera hasta el COMMIT de A)
-- =============================================================================
-- Sesion B. Debe lanzarse SIMULTANEAMENTE con 03_bloqueo_A.
-- Cronologia interna:
--   t ~ 0  : inicio.
--   t ~ 3  : intenta ACTUALIZAR la misma fila. InnoDB la tiene bloqueada por
--            A (X lock desde t ~ 0.3): el UPDATE de B QUEDA EN ESPERA.
--   t ~ 10.3: A confirma; el bloqueo se libera y el UPDATE de B AVANZA.
--   inmediatamente despues: mide el valor final (esperado 21 = 10 + 1 de A
--            + 10 de B) y registra NOW(6) antes/despues del UPDATE para
--            calcular la espera real observada.
-- La espera se resuelve por el COMMIT de A (sin timeout ni errores).
-- =============================================================================
USE kiro_labo_concurrencia;
SET SESSION tx_isolation = 'REPEATABLE-READ';

SELECT CONNECTION_ID() AS conexion_B, NOW(6) AS t_inicio_B, @@session.tx_isolation AS nivel_B;

SELECT SLEEP(3) AS espera_B_antes_de_intentar;

SET SESSION innodb_lock_wait_timeout = 30;
SELECT NOW(6) AS t_antes_update_B, @@session.innodb_lock_wait_timeout AS timeout_b_s;

START TRANSACTION;

UPDATE asiento SET valor = valor + 10, etiqueta = 'B_post_bloqueo' WHERE id = 1;

SELECT NOW(6) AS t_despues_update_B, valor, etiqueta FROM asiento WHERE id = 1;

COMMIT;
SELECT NOW(6) AS t_commit_B;

SELECT 'FIN_B' AS fin;
