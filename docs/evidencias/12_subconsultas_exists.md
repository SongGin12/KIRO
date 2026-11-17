# Evidencia 12 - Subconsultas con EXISTS y NOT EXISTS (comparacion con IN)

- Servidor: MariaDB 10.4.32-MariaDB
- Fecha de la prueba: 2026-11-16
- Script reproducible: `database/consultas/QUERY_06_subconsultas_exists.sql`
- Metodo de ejecucion: `mysql.exe -u root --default-character-set=utf8mb4 -t Kiro < QUERY_06_subconsultas_exists.sql` (codigo de salida 0, salida completa reproducida mas abajo).
- Naturaleza de la prueba: EXCLUSIVAMENTE de lectura. El script no contiene ninguna sentencia de escritura (verificado por inspeccion: 0 coincidencias de INSERT/UPDATE/DELETE/DROP/CREATE/ALTER/TRUNCATE/CALL/SET al inicio de linea). No se modifico ningun dato ni estructura de `Kiro`.

## 1. Objetivo

Demostrar el operador `EXISTS` y su negacion `NOT EXISTS` como operadores de subconsulta correlacionada sobre las tablas reales de KIRO, y compararlos didacticamente con `IN`. Esta evidencia completa la cobertura de subconsultas de la asignatura, hasta ahora limitada a `IN` y subconsultas no correlacionadas (QUERY_02, seccion 08).

## 2. Consultas ejecutadas (4 bloques, todos SELECT)

| Bloque | Consulta | Que demuestra |
|---|---|---|
| 0 | Contexto de datos: `SELECT estado, COUNT(*) FROM ACTIVIDAD/PROYECTO GROUP BY estado` | Los datos semilla reales sobre los que se apoyan los resultados (sin datos inventados) |
| 1 | `EXISTS` sobre ACTIVIDAD correlacionada con USUARIO | La subconsulta se evalua por fila externa; devuelve el usuario cuando existe al menos una actividad pendiente suya |
| 2 | `NOT EXISTS` sobre PROYECTO correlacionada con USUARIO | Devuelve el usuario cuando la subconsulta NO produce ninguna fila (sin proyectos en progreso) |
| 3 | La misma pregunta del bloque 1 con `IN` (no correlacionada) y con `EXISTS` | Comparacion didactica: ambas devuelven exactamente el mismo resultado |
| 4 | `EXISTS` + `NOT EXISTS` combinados en una sola consulta | Condiciones de existencia y no existencia sobre relaciones distintas en la misma consulta |

## 3. Resultados reales (salida exacta de la ejecucion)

**Bloque 0 - contexto de datos:**

| Tabla | estado | filas |
|---|---|---|
| ACTIVIDAD | Completada | 2 |
| ACTIVIDAD | En progreso | 4 |
| ACTIVIDAD | Pendiente | 4 |
| PROYECTO | Completado | 2 |
| PROYECTO | En progreso | 5 |
| PROYECTO | Pendiente | 3 |

**Bloque 1 - EXISTS: usuarios con al menos una actividad 'Pendiente' (4 filas):**

| id_usuario | nombre |
|---|---|
| 3 | Diego Vargas |
| 7 | Andres Choque |
| 9 | Javier Morales |
| 10 | Camila Torres |

**Bloque 2 - NOT EXISTS: usuarios sin ningun proyecto 'En progreso' (5 filas):**

| id_usuario | nombre |
|---|---|
| 3 | Diego Vargas |
| 5 | Miguel Rojas |
| 7 | Andres Choque |
| 9 | Javier Morales |
| 10 | Camila Torres |

**Bloque 3 - IN vs EXISTS (mismas salidas una junto a la otra):** ambas versiones devolvieron exactamente las mismas 4 filas: ids 3, 7, 9 y 10 (Diego Vargas, Andres Choque, Javier Morales, Camila Torres). Resultado identico consulta por consulta.

**Bloque 4 - EXISTS + NOT EXISTS combinados (4 filas):**

| id_usuario | nombre |
|---|---|
| 3 | Diego Vargas |
| 7 | Andres Choque |
| 9 | Javier Morales |
| 10 | Camila Torres |

Coincide con lo esperado a partir del bloque 0: los 4 usuarios con actividad pendiente (3, 7, 9, 10) tambien carecen de proyectos en progreso (ninguno aparece entre 1, 2, 4, 6, 8).

## 4. Diferencia conceptual entre IN, EXISTS y NOT EXISTS

- **IN (subconsulta no correlacionada):** calcula UNA vez el conjunto de valores de la subconsulta y compara el valor de la fila externa contra ese conjunto. En el bloque 3a, primero se calcula el conjunto de `id_usuario` con actividad pendiente y luego se filtra USUARIO por pertenencia.
- **EXISTS (subconsulta correlacionada):** se evalua POR CADA fila externa y devuelve verdadero si la subconsulta produce al menos una fila; el valor de las columnas es irrelevante (por convencion se escribe `SELECT 1`). Solo importa la existencia.
- **NOT EXISTS:** la negacion logica de EXISTS: verdadero cuando la subconsulta correlacionada no produce ninguna fila para la fila externa (bloque 2: usuarios sin proyectos en progreso; bloque 4: combinado con EXISTS).
- En casos como este (subconsultas sobre tablas reales con el mismo resultado), `IN` y `EXISTS` son reescribibles entre si; la diferencia didactica clave es la correlacion y la semantica de existencia. `NOT EXISTS` no tiene equivalente directo con `IN` para expresar "no pertenece al conjunto" cuando se necesita la forma correlacionada (`NOT IN` con columnas nulas tiene semantica trampa; `NOT EXISTS` evita ese problema).

## 5. Fecha y entorno de ejecucion

- Fecha: 16 de noviembre de 2026.
- Entorno: XAMPP local, MariaDB 10.4.32-MariaDB, motor InnoDB, base `Kiro` (charset utf8mb4), cliente `mysql.exe` con `--default-character-set=utf8mb4`.

## 6. Confirmacion de solo lectura e integridad

- El script contiene exclusivamente sentencias `SELECT` (verificacion automatizada: 0 sentencias de escritura).
- Al finalizar la ejecucion se repitieron las guardas de integridad del proyecto: CHECKSUM de las 12 tablas identico al baseline historico, conteo total de registros 122, y los objetos SQL sin cambios (4 vistas, 5 funciones, 2 procedimientos, 2 triggers). La base `Kiro` no fue modificada.
