# Evidencia 05 - Analisis EXPLAIN de consultas representativas de KIRO

- Servidor: MariaDB 10.4.32-MariaDB, base `Kiro`
- Fecha de analisis: 2026-11-16
- Metodo: `EXPLAIN` sobre 6 consultas representativas (mas 1 complementaria). Todas las ejecuciones fueron de solo lectura. No se crearon ni modificaron indices, no se ejecuto `ANALYZE TABLE` ni `EXPLAIN ANALYZE`, y no se altero ninguna tabla, registro u objeto.
- Las consultas usan listas de columnas explicitas; la columna `hash_contrasena` de `USUARIO` nunca se selecciona. Los literales de prueba no corresponden a datos reales de usuarios.

## 1. Contexto e hipotesis previas

Los 19 indices secundarios del esquema estan disenados para las operaciones mas frecuentes de KIRO: lectura de datos por usuario, fechas y estados, y trazabilidad de auditoria. El analisis busca verificar si el optimizador los utiliza realmente en consultas equivalentes a las de la aplicacion (paginas Inicio y Configuracion) y a los objetos SQL.

Estados reales verificados antes del analisis (SELECT DISTINCT de solo lectura):

| Tabla | Valores de `estado` |
|---|---|
| cita | Pendiente, Confirmada, Cancelada |
| actividad | Pendiente, En progreso, Completada |
| proyecto | En progreso, Pendiente, Completado |

## 2. Consultas, resultados reales e interpretacion

### Q1 - Busqueda por clave primaria

```sql
EXPLAIN SELECT id_usuario, nombre, correo, fecha_registro
FROM usuario WHERE id_usuario = 1;
```

| id | select_type | table | type | possible_keys | key | key_len | ref | rows | Extra |
|---|---|---|---|---|---|---|---|---|---|
| 1 | SIMPLE | usuario | const | PRIMARY | PRIMARY | 4 | const | 1 | (vacio) |

**Observado:** acceso `const` por `PRIMARY` con `key_len = 4` (la clave es un INT de 4 bytes) y 1 fila estimada. `possible_keys = key`, es decir, no hay ambiguedad.

**Comparacion con la expectativa:** coincide exactamente. Es el tipo de acceso mas economico: el valor de la PK localiza la fila directamente en el arbol B+ del indice.

**Interpretacion:** la pagina Configuracion consulta el usuario por identificador; este patron usa el camino optimo.

### Q2 - Busqueda por indice unico (correo)

```sql
EXPLAIN SELECT id_usuario, nombre FROM usuario
WHERE correo = 'prueba-no-existente@ejemplo.test';
```

| id | select_type | table | type | possible_keys | key | key_len | ref | rows | Extra |
|---|---|---|---|---|---|---|---|---|---|
| 1 | SIMPLE | NULL | NULL | NULL | NULL | NULL | NULL | NULL | Impossible WHERE noticed after reading const tables |

**Observado:** el literal no existe en la tabla; el optimizador resolvio la busqueda como lectura de tabla `const` (valor unico) durante la optimizacion y constato que ninguna fila podia cumplirla. Por eso la fila principal aparece vacia con `Extra = Impossible WHERE noticed after reading const tables`.

**Comparacion con la expectativa:** la expectativa era `type = const` con `uq_usuario_correo`. El resultado observado es compatible con esa expectativa: la via de indice unico se recorrio en la fase de const-tables (eso es lo que permite detectar la imposibilidad sin escanear la tabla). Sin embargo, la salida no muestra el uso explicito del indice, por lo que se agrego la consulta complementaria Q2b.

### Q2b (complementaria) - Indice unico con valor existente

```sql
EXPLAIN SELECT u.id_usuario, u.nombre FROM usuario u
WHERE u.correo = (SELECT c.correo FROM usuario c WHERE c.id_usuario = 1);
```

| id | select_type | table | type | possible_keys | key | key_len | ref | rows | Extra |
|---|---|---|---|---|---|---|---|---|---|
| 1 | PRIMARY | u | const | uq_usuario_correo | uq_usuario_correo | 602 | const | 1 | (vacio) |
| 2 | SUBQUERY | c | const | PRIMARY | PRIMARY | 4 | const | 1 | (vacio) |

**Observado:** `type = const` sobre `uq_usuario_correo` con `key_len = 602` (correo es VARCHAR(150) en utf8mb4: 150 x 4 = 600 bytes de caracteres + 2 bytes de longitud). La subconsulta sobre el id se resuelve como `const` por `PRIMARY`.

**Comparacion con la expectativa:** coincide con la hipotesis inicial. La unicidad del correo (decision de diseno documentada en el plan, seccion 8.1.2) se materializa en un indice UNIQUE que el optimizador aprovecha.

### Q3 - Filtrado por usuario con rango de fecha y orden temporal (citas)

```sql
EXPLAIN SELECT id_cita, titulo, fecha_inicio, duracion_minutos
FROM cita WHERE id_usuario = 1 AND fecha_inicio >= '2026-11-16 00:00:00'
ORDER BY fecha_inicio;
```

| id | select_type | table | type | possible_keys | key | key_len | ref | rows | Extra |
|---|---|---|---|---|---|---|---|---|---|
| 1 | SIMPLE | cita | range | ix_cita_usuario_fecha | ix_cita_usuario_fecha | 9 | NULL | 1 | Using index condition |

**Observado:** `type = range` sobre `ix_cita_usuario_fecha` con `key_len = 9` (id_usuario INT: 4 bytes; fecha_inicio DATETIME: 5 bytes, no nullable). Las dos columnas del indice participan. No aparece `Using filesort`: el `ORDER BY fecha_inicio` aprovecha el orden interno del indice (el rango sobre la segunda columna conserva la secuencia temporal).

**Comparacion con la expectativa:** coincide. Este patron equivale a la vista `vw_kiro_proximas_citas` y a la consulta de proxima cita de la aplicacion: prefijo izquierdo (usuario) + rango y orden por fecha.

### Q4 - JOIN actividad-proyecto por la relacion compuesta

```sql
EXPLAIN SELECT a.id_actividad, a.titulo, a.estado, p.nombre
FROM actividad a JOIN proyecto p
  ON p.id_proyecto = a.id_proyecto AND p.id_usuario = a.id_usuario
WHERE a.id_usuario = 1 ORDER BY a.fecha_limite;
```

| id | select_type | table | type | possible_keys | key | key_len | ref | rows | Extra |
|---|---|---|---|---|---|---|---|---|---|
| 1 | SIMPLE | a | ref | ix_actividad_usuario, ix_actividad_proyecto_usuario, ix_actividad_proyecto_estado_fecha | ix_actividad_usuario | 4 | const | 1 | Using where; Using filesort |
| 1 | SIMPLE | p | eq_ref | PRIMARY, uq_proyecto_id_usuario, ix_proyecto_usuario | PRIMARY | 4 | kiro.a.id_proyecto | 1 | Using where |

**Observado:** la tabla conductora es `a` (actividad), con acceso `ref` por `ix_actividad_usuario` (4 bytes = solo id_usuario). El join resuelve `p` con `eq_ref` (una fila por fila de `a`): el optimizador eligio `PRIMARY` (4 bytes) sobre `uq_proyecto_id_usuario` (8 bytes), que tambien era candidata; escoge la clave mas corta que garantiza unicidad. Aparece `Using filesort` por el `ORDER BY a.fecha_limite`: ningun indice de `actividad` por usuario tiene a fecha_limite despues de id_usuario.

**Comparacion con la expectativa:** el `eq_ref` y la eleccion del indice de usuario coinciden. La diferencia observada es la eleccion de `PRIMARY` en lugar de `uq_proyecto_id_usuario` y el `filesort`, que no se habia previsto: con 10 filas el ordenamiento es trivial y no indica un problema de diseno, pero tampoco una mejora medida.

### Q5 - Filtro por proyecto, estado y fecha (actividades)

```sql
EXPLAIN SELECT id_actividad, titulo, estado, fecha_limite
FROM actividad WHERE id_proyecto = 1 AND estado = 'Pendiente'
AND fecha_limite >= '2026-11-16' ORDER BY fecha_limite;
```

| id | select_type | table | type | possible_keys | key | key_len | ref | rows | Extra |
|---|---|---|---|---|---|---|---|---|---|
| 1 | SIMPLE | actividad | range | ix_actividad_proyecto_usuario, ix_actividad_proyecto_estado_fecha | ix_actividad_proyecto_estado_fecha | 90 | NULL | 1 | Using where |

**Observado:** `type = range` sobre el indice de 3 columnas `ix_actividad_proyecto_estado_fecha`, con `key_len = 90`: id_proyecto (4) + estado VARCHAR(20) en utf8mb4 (80 de caracteres + 2 de longitud + 1 de nulidad = 83) + fecha_limite DATE (3). El valor 90 prueba que las tres columnas del indice participaron en el acceso.

**Comparacion con la expectativa:** coincide. Este es el caso de estudio mas completo del analisis: el orden de las columnas del indice compuesto (entidad, estado, fecha) responde exactamente al patron de consulta previsto, y `key_len` lo demuestra numericamente.

### Q6 - Consulta de auditoria (entidad + registro)

```sql
EXPLAIN SELECT tipo_accion, descripcion, fecha_accion
FROM historial_accion WHERE entidad_afectada = 'ACTIVIDAD'
AND id_registro_afectado = 1 ORDER BY fecha_accion;
```

| id | select_type | table | type | possible_keys | key | key_len | ref | rows | Extra |
|---|---|---|---|---|---|---|---|---|---|
| 1 | SIMPLE | historial_accion | ref | ix_historial_entidad_registro | ix_historial_entidad_registro | 207 | const, const | 1 | Using index condition; Using where; Using filesort |

**Observado:** `type = ref` con `ref = const, const` (ambas columnas de busqueda son literales) y `key_len = 207` (entidad_afectada VARCHAR(50): 200 + 2 + 1 de nulidad = 203; id_registro_afectado INT nullable: 4). Las dos columnas del indice se usan. Aparece `Using filesort` por el `ORDER BY fecha_accion`: el indice auditado ordena por entidad y registro, no por fecha.

**Comparacion con la expectativa:** el uso del indice de auditoria coincide. El `filesort` es una observacion no prevista; con el volumen actual es inofensivo y no se midio ningun costo real.

## 3. Sintesis de resultados observados

| Consulta | Acceso observado | Indice usado | key_len | Coincide con lo previsto |
|---|---|---|---|---|
| Q1 | const | PRIMARY | 4 | Si |
| Q2 | const-tables (literal inexistente) | via uq_usuario_correo (implicita) | - | Compatible |
| Q2b | const | uq_usuario_correo | 602 | Si |
| Q3 | range | ix_cita_usuario_fecha | 9 | Si |
| Q4 | ref + eq_ref | ix_actividad_usuario + PRIMARY | 4 / 4 | Si (con 2 observaciones no previstas) |
| Q5 | range | ix_actividad_proyecto_estado_fecha | 90 | Si |
| Q6 | ref | ix_historial_entidad_registro | 207 | Si (con filesort no previsto) |

Conclusiones observadas (no medidas): el plan de indices cubre los patrones de consulta previstos; todas las consultas usan indices (ningun `type = ALL`); `key_len` confirma el uso efectivo de columnas de indice compuesto; el optimizador prefiere claves mas cortas entre candidatos unicos.

## 4. Limitaciones del analisis

1. **Volumen minimo:** las tablas tienen 10-11 filas. Con cardinalidad tan baja, el optimizador puede elegir planes que con miles de filas serian distintos, y las diferencias de costo entre planes son inobservables.
2. **Estimaciones, no mediciones:** `rows` es una estimacion del optimizador; no se ejecuto `ANALYZE TABLE` ni `EXPLAIN ANALYZE` (fuera del alcance autorizado), por lo que no hay tiempos ni conteos reales de lectura.
3. **key = NULL no es un defecto:** con pocas filas, escanear la tabla puede ser mas barato que usar un indice. Ninguna consulta observada cayo en `ALL`, pero una conclusion de este analisis no debe generalizarse a volumenes mayores sin re-analizar.
4. **El ORDER BY no cubierto produce filesort:** en Q4 y Q6 se observo `Using filesort`. Con 10 filas es despreciable; documentarlo no equivale a haber medido una mejora posible (no se crearon ni se proponen indices nuevos).
5. **Datos de prueba:** los resultados reflejan el estado del entorno de laboratorio; reejecutar el analisis tras una carga de datos realista requeriria esta misma evidencia actualizada.

**Nota de honestidad:** este analisis verifica el uso correcto de los indices existentes; no afirma ninguna mejora de rendimiento medida, y ninguna conclusion debe presentarse como optimizacion comprobada.
