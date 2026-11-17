-- =============================================================================
-- KIRO - QUERY_05 - 09: LIMPIEZA DEL LABORATORIO
-- =============================================================================
-- Ejecutar SOLO al final de todos los experimentos y despues de verificar
-- (fuera del script) que NO quedan transacciones abiertas
-- (information_schema.INNODB_TRX = 0). Elimina EXCLUSIVAMENTE la base creada
-- por esta ejecucion: kiro_labo_concurrencia. Ninguna otra base se toca.
-- =============================================================================
USE Kiro;

DROP DATABASE kiro_labo_concurrencia;

-- Verificacion (solo lectura): la base no debe existir
SELECT COUNT(*) AS bases_laboratorio_restantes
FROM information_schema.SCHEMATA
WHERE SCHEMA_NAME = 'kiro_labo_concurrencia';

SELECT 'FIN_09' AS fin;
