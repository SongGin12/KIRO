# Evidencia 06 - Consultas SQL avanzadas sobre KIRO

- Servidor: MariaDB 10.4.32-MariaDB, base `Kiro`
- Fecha de analisis: 2026-11-16
- Metodo: 8 consultas `SELECT` exclusivamente de lectura (JOIN, GROUP BY, HAVING, subconsultas, CASE, UNION). No se ejecuto ninguna instruccion de escritura ni DDL y no se modifico la base de datos.
- Proposito academico: cubrir la construccion SQL avanzada del contenido de la asignatura con consultas que tienen sentido funcional para KIRO (agenda, proyectos y actividades, notas y categorias).
- Los datos provienen de la carga semilla de prueba; los titulos son de ejemplo y no contienen informacion personal real.

---

## C1 - INNER JOIN: actividades activas con su proyecto

**Proposito:** listar las actividades no completadas junto al nombre del proyecto al que pertenecen, respetando la relacion compuesta (el proyecto debe ser del mismo usuario).

**Explicacion sencilla:** `INNER JOIN` combina filas de dos tablas cuando la condicion de union se cumple en ambas; las filas que no emparejan desaparecen del resultado. La FK compuesta `(id_proyecto, id_usuario)` evita cruzar actividades de un usuario con proyectos de otro.

```sql
SELECT a.titulo AS actividad, p.nombre AS proyecto, a.estado, a.fecha_limite
FROM actividad a
INNER JOIN proyecto p
  ON p.id_proyecto = a.id_proyecto
 AND p.id_usuario  = a.id_usuario
WHERE a.estado <> 'Completada'
ORDER BY a.fecha_limite;
```

**Resultado real (6 filas):**

| actividad | proyecto | estado | fecha_limite |
|---|---|---|---|
| Preparar informe | Proyecto universitario | En progreso | 2026-11-15 |
| Revisar capacitacion | Capacitacion laboral | En progreso | 2026-11-18 |
| Organizar alimentacion | Plan de bienestar | Pendiente | 2026-11-20 |
| Planificar rutina | Rutina de ejercicios | Pendiente | 2026-11-22 |
| Disenar pantalla | Aplicacion personal | En progreso | 2026-11-25 |
| Redactar publicacion | Blog personal | En progreso | 2026-11-28 |

**Lectura:** las 2 actividades independientes (sin proyecto) no aparecen, porque el INNER JOIN descarta las filas sin emparejar; ese caso se cubre en C2.

---

## C2 - LEFT JOIN: actividades independientes (sin proyecto)

**Proposito:** mostrar las actividades que NO pertenecen a ningun proyecto, que el INNER JOIN de C1 omitiria. Responde a la regla de negocio RN-08: una actividad pertenece a un proyecto o es independiente.

**Explicacion sencilla:** `LEFT JOIN` conserva TODAS las filas de la tabla izquierda (actividad) aunque no encuentren pareja en la derecha (proyecto); las columnas de la derecha quedan `NULL`. El filtro `WHERE p.id_proyecto IS NULL` deja solo las que no emparejaron.

```sql
SELECT a.id_actividad, a.titulo, a.estado
FROM actividad a
LEFT JOIN proyecto p
  ON p.id_proyecto = a.id_proyecto
WHERE p.id_proyecto IS NULL
ORDER BY a.id_actividad;
```

**Resultado real (2 filas):**

| id_actividad | titulo | estado |
|---|---|---|
| 9 | Comprar materiales | Pendiente |
| 10 | Organizar escritorio | Pendiente |

**Lectura:** coincide con los datos semilla: exactamente 2 actividades se insertaron con `id_proyecto NULL`. Entre C1 y C2 se cubren los 10 registros de `actividad`.

---

## C3 - GROUP BY: actividades por estado

**Proposito:** resumir cuantas actividades hay en cada estado, en lugar de listar filas individuales.

**Explicacion sencilla:** `GROUP BY` agrupa las filas que comparten el mismo valor de `estado` y las funciones de agregacion (`COUNT`) resumen cada grupo en una sola fila.

```sql
SELECT estado, COUNT(*) AS total
FROM actividad
GROUP BY estado
ORDER BY total DESC;
```

**Resultado real (3 filas):**

| estado | total |
|---|---|
| Pendiente | 4 |
| En progreso | 4 |
| Completada | 2 |

**Lectura:** 4 + 4 + 2 = 10 filas, consistente con el conteo total de la tabla. La vista `vw_kiro_actividades_pendientes` (evidencia 02) es el caso particular de este resumen cuando solo interesan los estados activos.

---

## C4 - HAVING: usuarios con 2 o mas citas pendientes

**Proposito:** identificar a que usuarios hay que avisarles de agendas con varios compromisos sin confirmar. Es un filtro sobre grupos, no sobre filas.

**Explicacion sencilla:** `WHERE` filtra filas ANTES de agrupar (solo citas `Pendiente`); `HAVING` filtra DESPUES de agrupar, usando el resultado de la agregacion (`COUNT(*) >= 2`).

```sql
SELECT id_usuario, COUNT(*) AS citas_pendientes
FROM cita
WHERE estado = 'Pendiente'
GROUP BY id_usuario
HAVING COUNT(*) >= 2
ORDER BY citas_pendientes DESC;
```

**Resultado real (1 fila):**

| id_usuario | citas_pendientes |
|---|---|
| 1 | 2 |

**Lectura:** con los datos semilla, solo el usuario 1 tiene 2 o mas citas pendientes (las demas tienen 1 o 0); el filtro `HAVING` los descarta. Se muestran identificadores, no datos personales.

---

## C5 - Subconsulta escalar: citas con duracion mayor al promedio

**Proposito:** encontrar las citas mas largas de lo habitual, comparando cada cita contra el promedio de todas.

**Explicacion sencilla:** la subconsulta entre parentesis se evalua primero y devuelve UN solo valor (el promedio redondeado); la consulta externa usa ese valor como condicion. Es una subconsulta escalar (un valor, no una tabla).

```sql
SELECT c.id_cita, c.titulo, c.duracion_minutos
FROM cita c
WHERE c.duracion_minutos >
      (SELECT ROUND(AVG(duracion_minutos), 0) FROM cita)
ORDER BY c.duracion_minutos DESC;
```

**Resultado real (2 filas):**

| id_cita | titulo | duracion_minutos |
|---|---|---|
| 9 | Sesion fotografica | 120 |
| 5 | Club de lectura | 90 |

**Lectura:** el promedio de las 11 citas es 61 minutos; solo las citas de 90 y 120 minutos lo superan.

---

## C5b - Subconsulta con IN: categorias que tienen al menos una nota

**Proposito:** recuperar las categorias que efectivamente se usan en alguna nota, sin necesidad de JOIN ni DISTINCT en la tabla externa.

**Explicacion sencilla:** la subconsulta produce una lista de valores (`id_categoria` con notas) y `IN` comprueba si cada categoria pertenece a esa lista. A diferencia de C5, aqui la subconsulta devuelve muchas filas.

```sql
SELECT ca.id_categoria, ca.nombre, ca.tipo
FROM categoria ca
WHERE ca.id_categoria IN
      (SELECT n.id_categoria FROM nota n)
ORDER BY ca.id_categoria;
```

**Resultado real (10 filas):**

| id_categoria | nombre | tipo |
|---|---|---|
| 1 | Estudios | Personal |
| 2 | Trabajo | Personal |
| 3 | Salud | Personal |
| 4 | Finanzas | Personal |
| 5 | Lecturas | Personal |
| 6 | Proyectos | Personal |
| 7 | Rutinas | Personal |
| 8 | Inspiracion | Personal |
| 9 | Ocio | Personal |
| 10 | Aprendizaje | Personal |

**Lectura:** con los datos semilla cada usuario tiene una nota en su propia categoria, por lo que las 10 categorias salen en la lista; el patron de consulta es lo que se demuestra, y con datos reales filtraria las categorias sin uso. La vista `vw_kiro_notas_categorias` resuelve el caso inverso (JOIN nota-categoria).

---

## C6 - CASE: clasificacion de actividades por vencimiento

**Proposito:** convertir la fecha limite y el estado en una etiqueta de urgencia util para la agenda: vencida, vence hoy, vigente o terminada.

**Explicacion sencilla:** `CASE ... WHEN ... THEN ... ELSE ... END` evalua condiciones en orden y devuelve el valor de la primera que se cumple. Cada fila obtiene su etiqueta sin modificar ningun dato.

```sql
SELECT id_actividad, titulo, estado, fecha_limite,
       CASE
         WHEN estado = 'Completada'  THEN 'Terminada'
         WHEN fecha_limite < CURDATE() THEN 'Vencida'
         WHEN fecha_limite = CURDATE() THEN 'Vence hoy'
         ELSE 'Vigente'
       END AS clasificacion
FROM actividad
ORDER BY clasificacion, fecha_limite;
```

**Resultado real (10 filas, al 2026-11-16):**

| id_actividad | titulo | estado | fecha_limite | clasificacion |
|---|---|---|---|---|
| 5 | Terminar lectura | Completada | 2026-11-10 | Terminada |
| 4 | Registrar gastos | Completada | 2026-11-12 | Terminada |
| 9 | Comprar materiales | Pendiente | 2026-11-16 | Vence hoy |
| 1 | Preparar informe | En progreso | 2026-11-15 | Vencida |
| 10 | Organizar escritorio | Pendiente | 2026-11-17 | Vigente |
| 2 | Revisar capacitacion | En progreso | 2026-11-18 | Vigente |
| 3 | Organizar alimentacion | Pendiente | 2026-11-20 | Vigente |
| 7 | Planificar rutina | Pendiente | 2026-11-22 | Vigente |
| 6 | Disenar pantalla | En progreso | 2026-11-25 | Vigente |
| 8 | Redactar publicacion | En progreso | 2026-11-28 | Vigente |

**Lectura:** la primera condicion (`Completada`) gana siempre, de modo que una actividad completada nunca se marca como vencida aunque su fecha haya pasado. El resultado depende de la fecha de ejecucion (`CURDATE()`); al avanzar los dias la etiqueta `Vigente` de una fila puede cambiar a `Vence hoy` y luego a `Vencida`.

---

## C7 - UNION ALL: actividades vencidas + proyectos vencidos

**Proposito:** consolidar en una sola lista todo lo que quedo atrasado en la agenda del usuario, sea actividad o proyecto. Es el insumo natural de un panel de "vencidos" de KIRO.

**Explicacion sencilla:** `UNION ALL` apila los resultados de dos consultas que devuelven las mismas columnas (mismo numero y tipos compatibles), SIN eliminar duplicados: si una actividad y un proyecto coincidieran en todo, ambas filas aparecen. Se etiqueta cada fila con su origen para poder distinguirlas.

```sql
SELECT a.id_usuario, 'ACTIVIDAD' AS origen, a.titulo AS elemento, a.fecha_limite AS fecha
FROM actividad a
WHERE a.estado <> 'Completada' AND a.fecha_limite < CURDATE()
UNION ALL
SELECT p.id_usuario, 'PROYECTO', p.nombre, p.fecha_fin
FROM proyecto p
WHERE p.estado <> 'Completado' AND p.fecha_fin < CURDATE()
ORDER BY fecha;
```

**Resultado real (1 fila, al 2026-11-16):**

| id_usuario | origen | elemento | fecha |
|---|---|---|---|
| 1 | ACTIVIDAD | Preparar informe | 2026-11-15 |

**Lectura:** hoy solo hay una cosa vencida en los datos semilla: la actividad del usuario 1. Todos los proyectos tienen `fecha_fin` futura (el mas cercano vence el 2026-11-30), por lo que el segundo bloque de la UNION no aporta filas; la estructura de la consulta es lo que se demuestra. En C6 la misma actividad figuraba como `Vencida`: la vista combinada agrega la dimension `origen` para mezclar entidades distintas en un solo listado.

---

## Cobertura cubierta por esta evidencia

| Construccion | Consulta | Verificacion |
|---|---|---|
| INNER JOIN | C1 | 6 filas reales |
| LEFT JOIN | C2 | 2 filas reales (caso NULL) |
| GROUP BY | C3 | 3 grupos, suma = 10 filas |
| HAVING | C4 | filtro de grupo aplicado (1 de 10 grupos sobrevive) |
| Subconsulta escalar | C5 | 2 filas reales |
| Subconsulta IN | C5b | 10 filas reales |
| CASE | C6 | 4 etiquetas reales |
| UNION ALL | C7 | 2 bloques combinados, 1 fila |

## Limitaciones

- Los resultados dependen de la fecha de ejecucion (C6 y C7 usan `CURDATE()`) y del volumen semilla (10 filas por tabla); con datos reales los conteos y listas serian distintos, aunque el patron de cada consulta no cambia.
- No se crearon vistas, indices ni objetos nuevos: las consultas son operaciones de lectura puntuales y reproducibles.
- El caso `HAVING` y el bloque de proyectos de `UNION` no devuelven filas abundantes con los datos de prueba; se documentan igual porque lo que se evidencia es la construccion SQL y su comportamiento, no el volumen.
