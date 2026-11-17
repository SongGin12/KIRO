-- =============================================================================
-- KIRO - QUERY_06: SUBCONSULTAS CON EXISTS Y NOT EXISTS (COMPARACION CON IN)
-- =============================================================================
-- Proyecto:  KIRO (Bases de Datos II)
-- Base:      Kiro - MariaDB 10.4.32 - InnoDB
-- Ejecucion: mysql.exe -u root --default-character-set=utf8mb4 -t Kiro <
--            QUERY_06_subconsultas_exists.sql
--
-- OBJETIVO ACADEMICO
--   Demostrar el operador EXISTS y su negacion NOT EXISTS como operadores de
--   subconsulta correlacionada, y compararlos didacticamente con IN.
--
--   - EXISTS (subconsulta): devuelve verdadero si la subconsulta correlacionada
--     produce AL MENOS una fila para la fila evaluada; no importa el valor,
--     solo la existencia. Por convencion se usa SELECT 1 o SELECT *.
--   - NOT EXISTS: verdadero cuando la subconsulta NO produce ninguna fila.
--   - IN (lista o subconsulta NO correlacionada): compara el valor contra un
--     conjunto de valores ya calculado. Con subconsultas sobre tablas reales,
--     EXISTS y IN suelen poder reescribirse entre si; la diferencia didactica
--     clave es la correlacion (EXISTS se evalua por fila externa; IN calcula
--     el conjunto una vez).
--
-- SEGURIDAD: este script contiene EXCLUSIVAMENTE consultas SELECT de lectura.
--   No ejecuta INSERT, UPDATE, DELETE, DDL ni CREATE de ningun tipo. No
--   modifica datos ni estructura. Se apoya unicamente en los datos semilla
--   existentes (verificados en la seccion 0), sin inventar resultados.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. CONTEXTO DE DATOS (solo lectura): los resultados posteriores son
--    reproducibles porque los datos verificados son estos.
-- -----------------------------------------------------------------------------
-- ACTIVIDAD: 10 filas (1 por usuario); con estado 'Pendiente': usuarios 3, 7, 9 y 10.
-- PROYECTO:  10 filas (1 por usuario); con estado 'En progreso': usuarios 1, 2, 4, 6 y 8.
-- USUARIO:   10 filas (ids 1 a 10).

SELECT 'ACTIVIDAD por estado' AS contexto, estado, COUNT(*) AS filas
FROM ACTIVIDAD GROUP BY estado;

SELECT 'PROYECTO por estado' AS contexto, estado, COUNT(*) AS filas
FROM PROYECTO GROUP BY estado;

-- -----------------------------------------------------------------------------
-- 1. EXISTS: usuarios que TIENEN al menos una actividad con estado 'Pendiente'.
--    Demuestra: la subconsulta correlacionada se evalua por cada fila de
--    USUARIO; devuelve el usuario cuando existe al menos una actividad
--    pendiente suya (no importan los valores, solo la existencia).
--    Resultado esperado con los datos actuales: 4 filas (ids 3, 7, 9 y 10).
-- -----------------------------------------------------------------------------
SELECT u.id_usuario, u.nombre
FROM USUARIO u
WHERE EXISTS (
    SELECT 1
    FROM ACTIVIDAD a
    WHERE a.id_usuario = u.id_usuario
      AND a.estado = 'Pendiente'
)
ORDER BY u.id_usuario;

-- -----------------------------------------------------------------------------
-- 2. NOT EXISTS: usuarios que NO tienen ningun proyecto con estado
--    'En progreso'.
--    Demuestra: la negacion del operador de existencia; se devuelve el usuario
--    cuando la subconsulta correlacionada NO produce ninguna fila.
--    Resultado esperado con los datos actuales: 5 filas (ids 3, 5, 7, 9 y 10).
-- -----------------------------------------------------------------------------
SELECT u.id_usuario, u.nombre
FROM USUARIO u
WHERE NOT EXISTS (
    SELECT 1
    FROM PROYECTO p
    WHERE p.id_usuario = u.id_usuario
      AND p.estado = 'En progreso'
)
ORDER BY u.id_usuario;

-- -----------------------------------------------------------------------------
-- 3. COMPARACION DIDACTICA EXISTS vs IN: la misma pregunta de la seccion 1
--    resuelta con IN (subconsulta no correlacionada que calcula el conjunto
--    de id_usuario con actividad pendiente). Ambas consultas deben devolver
--    EXACTAMENTE el mismo resultado.
-- -----------------------------------------------------------------------------
-- 3a. Version con IN.
SELECT u.id_usuario, u.nombre
FROM USUARIO u
WHERE u.id_usuario IN (
    SELECT a.id_usuario
    FROM ACTIVIDAD a
    WHERE a.estado = 'Pendiente'
)
ORDER BY u.id_usuario;

-- 3b. Version con EXISTS (identica a la seccion 1, repetida para comparar
--     las dos salidas una junto a la otra).
SELECT u.id_usuario, u.nombre
FROM USUARIO u
WHERE EXISTS (
    SELECT 1
    FROM ACTIVIDAD a
    WHERE a.id_usuario = u.id_usuario
      AND a.estado = 'Pendiente'
)
ORDER BY u.id_usuario;

-- -----------------------------------------------------------------------------
-- 4. EXISTS y NOT EXISTS combinados: usuarios que TIENEN al menos una
--    actividad pendiente Y ADEMÁS no tienen ningun proyecto en progreso.
--    Demuestra: la correlacion puede combinarse para expresar condiciones
--    de existencia y no existencia sobre relaciones distintas en la misma
--    consulta.
--    Resultado esperado con los datos actuales: 4 filas (ids 3, 7, 9 y 10).
-- -----------------------------------------------------------------------------
SELECT u.id_usuario, u.nombre
FROM USUARIO u
WHERE EXISTS (
    SELECT 1
    FROM ACTIVIDAD a
    WHERE a.id_usuario = u.id_usuario
      AND a.estado = 'Pendiente'
)
  AND NOT EXISTS (
    SELECT 1
    FROM PROYECTO p
    WHERE p.id_usuario = u.id_usuario
      AND p.estado = 'En progreso'
)
ORDER BY u.id_usuario;

SELECT 'FIN_QUERY_06' AS fin;
