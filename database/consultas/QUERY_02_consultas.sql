-- =============================================================================
-- KIRO - QUERY_02: CONSULTAS DE DEMOSTRACION Y COMPROBACION (SOLO LECTURA)
-- =============================================================================
-- Proyecto:  KIRO (Bases de Datos II)
-- Base:      Kiro - MariaDB 10.4.32
-- REGLA GENERAL: este archivo SOLO contiene operaciones de lectura (SELECT,
--   y un CALL de lectura documentado en la seccion 14). No modifica datos,
--   estructura ni permisos. Cada consulta fue ejecutada realmente sobre los
--   datos semilla; sus resultados reales estan documentados en docs/evidencias/
--   (05_analisis_explain.md y 06_consultas_avanzadas.md, 01, 02, 03 y 04).
--
-- REQUISITOS:
--   - La base Kiro construida con QUERY_01 (esquema + objetos + datos semilla).
--   - La mayoria de las consultas puede ejecutarlas el usuario de aplicacion
--     kiro_app (rol de solo lectura). Las secciones 11.3, 12 y 13 consultan
--     catalogos y objetos DEFINER; ejecutarlas con cuenta administradora.
--
-- NOTA DE DATOS: los resultados de las consultas con fechas relativas
--   (NOW(), CURDATE()) cambian cada dia; lo que se demuestra es el patron
--   de cada consulta, no el volumen de datos. Datos semilla: 10 usuarios
--   ficticios (id 1..10) y 120 registros de prueba; CITA e HISTORIAL_ACCION
--   tienen 1 registro extra de pruebas del laboratorio (11 y 11).
--
-- INDICE DE SECCIONES
--   01. Consultas basicas por clave primaria
--   02. Filtros y ordenamiento (WHERE, IN, ORDER BY, LIMIT)
--   03. INNER JOIN
--   04. LEFT JOIN
--   05. Agregaciones (COUNT, SUM, MIN, AVG)
--   06. GROUP BY
--   07. HAVING
--   08. Subconsultas
--   09. CASE
--   10. UNION y UNION ALL
--   11. Comprobacion de integridad referencial
--   12. Demostracion de vistas
--   13. Demostracion de funciones
--   14. Demostracion de SP de solo lectura (CALL, comentado por defecto)
-- =============================================================================

USE Kiro;

-- =============================================================================
-- SECCION 01: CONSULTAS BASICAS POR CLAVE PRIMARIA
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Consulta 01.1: Usuario por clave primaria
-- Objetivo: Recuperar el usuario identificador 1 con el acceso mas directo.
-- Demuestra: Busqueda por PK (type=const en EXPLAIN; evidencia 05, Q1).
-- ---------------------------------------------------------------------------
SELECT id_usuario, nombre, correo, fecha_registro
FROM USUARIO
WHERE id_usuario = 1;

-- ---------------------------------------------------------------------------
-- Consulta 01.2: Proxima cita futura del usuario
-- Objetivo: Mostrar la siguiente cita no cancelada a partir de ahora.
-- Demuestra: WHERE con varias condiciones + ORDER BY + LIMIT 1.
-- (Version plana de la consulta preparada de app/src/RepositorioInicio.php)
-- ---------------------------------------------------------------------------
SELECT id_cita, titulo, fecha_inicio, duracion_minutos, lugar, estado
FROM CITA
WHERE id_usuario = 1
  AND estado <> 'Cancelada'
  AND fecha_inicio >= NOW()
ORDER BY fecha_inicio ASC
LIMIT 1;

-- ---------------------------------------------------------------------------
-- Consulta 01.3: Ultima cita pasada del usuario
-- Objetivo: Contexto reciente cuando no hay citas futuras.
-- Demuestra: Ordenamiento descendente y LIMIT.
-- ---------------------------------------------------------------------------
SELECT id_cita, titulo, fecha_inicio, lugar, estado
FROM CITA
WHERE id_usuario = 1
  AND estado <> 'Cancelada'
  AND fecha_inicio < NOW()
ORDER BY fecha_inicio DESC
LIMIT 1;

-- =============================================================================
-- SECCION 02: FILTROS Y ORDENAMIENTO (WHERE, IN, ORDER BY, LIMIT)
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Consulta 02.1: Actividades aun no terminadas del usuario
-- Objetivo: Listar actividades activas ordenadas por fecha limite.
-- Demuestra: WHERE ... IN (lista blanca de estados) + ORDER BY + LIMIT.
-- (Version plana de actividadesProximas() de RepositorioInicio.php)
-- ---------------------------------------------------------------------------
SELECT id_actividad, titulo, fecha_limite, prioridad, estado
FROM ACTIVIDAD
WHERE id_usuario = 1
  AND estado IN ('Pendiente', 'En progreso')
ORDER BY fecha_limite ASC
LIMIT 3;

-- ---------------------------------------------------------------------------
-- Consulta 02.2: Proyectos en progreso con fecha de fin mas cercana
-- Objetivo: Saber que proyectos se cierran pronto.
-- Demuestra: Filtro por igualdad + orden por fecha + LIMIT.
-- ---------------------------------------------------------------------------
SELECT id_proyecto, nombre, estado, prioridad, fecha_fin
FROM PROYECTO
WHERE id_usuario = 1
  AND estado = 'En progreso'
ORDER BY fecha_fin ASC
LIMIT 3;

-- =============================================================================
-- SECCION 03: CONSULTAS CON INNER JOIN
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Consulta 03.1: Actividades asociadas a proyectos
-- Objetivo: Mostrar actividades activas junto al nombre de su proyecto.
-- Demuestra: Relacion entre tablas mediante INNER JOIN con la FK compuesta
--   (id_proyecto, id_usuario), que impide cruzar usuarios distintos.
-- Evidencia: docs/evidencias/06 (C1).
-- ---------------------------------------------------------------------------
SELECT a.titulo AS actividad, p.nombre AS proyecto, a.estado, a.fecha_limite
FROM ACTIVIDAD a
INNER JOIN PROYECTO p
  ON p.id_proyecto = a.id_proyecto
 AND p.id_usuario  = a.id_usuario
WHERE a.estado <> 'Completada'
ORDER BY a.fecha_limite;

-- ---------------------------------------------------------------------------
-- Consulta 03.2: Notas con su categoria
-- Objetivo: Mostrar cada nota junto al nombre y tipo de su categoria.
-- Demuestra: INNER JOIN simple por FK (id_categoria). Es la misma relacion
--   que encapsula la vista vw_kiro_notas_categorias (seccion 12).
-- ---------------------------------------------------------------------------
SELECT n.titulo AS nota, c.nombre AS categoria, c.tipo, n.fecha_creacion
FROM NOTA n
INNER JOIN CATEGORIA c
  ON c.id_categoria = n.id_categoria
ORDER BY n.id_nota;

-- =============================================================================
-- SECCION 04: CONSULTAS CON LEFT JOIN
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Consulta 04.1: Actividades independientes (sin proyecto)
-- Objetivo: Listar actividades que NO pertenecen a ningun proyecto.
-- Demuestra: LEFT JOIN conserva las filas de la izquierda sin pareja en la
--   derecha (quedan NULL); el filtro IS NULL deja solo las sin emparejar.
--   Responde a la regla de negocio RN-08.
-- Evidencia: docs/evidencias/06 (C2). Resultado esperado: 2 filas.
-- ---------------------------------------------------------------------------
SELECT a.id_actividad, a.titulo, a.estado
FROM ACTIVIDAD a
LEFT JOIN PROYECTO p
  ON p.id_proyecto = a.id_proyecto
WHERE p.id_proyecto IS NULL
ORDER BY a.id_actividad;

-- ---------------------------------------------------------------------------
-- Consulta 04.2: Notas sin categoria
-- Objetivo: Detectar notas sin clasificar (id_categoria NULL).
-- Demuestra: Segundo caso util de LEFT JOIN ... IS NULL.
-- Resultado esperado con datos semilla: 0 filas (todas tienen categoria);
-- la consulta es la herramienta, y con datos reales detectaria las sueltas.
-- ---------------------------------------------------------------------------
SELECT n.id_nota, n.titulo
FROM NOTA n
LEFT JOIN CATEGORIA c
  ON c.id_categoria = n.id_categoria
WHERE c.id_categoria IS NULL;

-- =============================================================================
-- SECCION 05: AGREGACIONES (COUNT, SUM, MIN, AVG)
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Consulta 05.1: Resumen de actividades del usuario
-- Objetivo: Total de actividades activas, la fecha limite mas proxima y
--   cuantas son de prioridad alta, en una sola fila.
-- Demuestra: COUNT(*), MIN() y SUM() de una expresion booleana
--   (prioridad = 'Alta' devuelve 1/0, y SUM los cuenta).
-- (Version plana de resumenActividades() de RepositorioInicio.php)
-- ---------------------------------------------------------------------------
SELECT COUNT(*)               AS total,
       MIN(fecha_limite)      AS proxima,
       SUM(prioridad = 'Alta') AS prioritarias
FROM ACTIVIDAD
WHERE id_usuario = 1
  AND estado IN ('Pendiente', 'En progreso');

-- ---------------------------------------------------------------------------
-- Consulta 05.2: Carga de agenda del usuario en minutos
-- Objetivo: Cuantas citas activas tiene y cuantos minutos en total ocupan.
-- Demuestra: SUM y AVG sobre una columna numerica con filtro de estado.
-- ---------------------------------------------------------------------------
SELECT COUNT(*)                    AS citas,
       SUM(duracion_minutos)       AS minutos_totales,
       ROUND(AVG(duracion_minutos), 1) AS promedio
FROM CITA
WHERE id_usuario = 1
  AND estado <> 'Cancelada';

-- =============================================================================
-- SECCION 06: GROUP BY
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Consulta 06.1: Actividades por estado
-- Objetivo: Resumen de cuantas actividades hay en cada estado.
-- Demuestra: GROUP BY agrupa filas por valor y COUNT resume cada grupo.
--   Esperado: Pendiente 4, En progreso 4, Completada 2 (suma = 10).
-- Evidencia: docs/evidencias/06 (C3).
-- ---------------------------------------------------------------------------
SELECT estado, COUNT(*) AS total
FROM ACTIVIDAD
GROUP BY estado
ORDER BY total DESC;

-- ---------------------------------------------------------------------------
-- Consulta 06.2: Citas por estado
-- Objetivo: Panorama de la agenda por estado de cita.
-- Demuestra: GROUP BY sobre otra tabla de estado; refuerza el patron.
-- ---------------------------------------------------------------------------
SELECT estado, COUNT(*) AS total
FROM CITA
GROUP BY estado
ORDER BY total DESC;

-- =============================================================================
-- SECCION 07: HAVING (filtro sobre grupos)
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Consulta 07.1: Usuarios con 2 o mas citas pendientes
-- Objetivo: Detectar agendas con varios compromisos sin confirmar.
-- Demuestra: Diferencia entre WHERE (filtra filas ANTES de agrupar) y
--   HAVING (filtra grupos DESPUES de agregar, usando COUNT(*)).
-- Evidencia: docs/evidencias/06 (C4). Resultado esperado: solo usuario 1.
-- ---------------------------------------------------------------------------
SELECT id_usuario, COUNT(*) AS citas_pendientes
FROM CITA
WHERE estado = 'Pendiente'
GROUP BY id_usuario
HAVING COUNT(*) >= 2
ORDER BY citas_pendientes DESC;

-- =============================================================================
-- SECCION 08: SUBCONSULTAS
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Consulta 08.1: Citas mas largas que el promedio general (escalar)
-- Objetivo: Comparar cada cita contra el promedio de todas.
-- Demuestra: Subconsulta escalar: se evalua primero y devuelve UN valor que
--   la consulta externa usa como condicion.
-- Evidencia: docs/evidencias/06 (C5).
-- ---------------------------------------------------------------------------
SELECT c.id_cita, c.titulo, c.duracion_minutos
FROM CITA c
WHERE c.duracion_minutos >
      (SELECT ROUND(AVG(duracion_minutos), 0) FROM CITA)
ORDER BY c.duracion_minutos DESC;

-- ---------------------------------------------------------------------------
-- Consulta 08.2: Categorias que tienen al menos una nota (IN)
-- Objetivo: Recuperar categorias efectivamente usadas en notas.
-- Demuestra: Subconsulta que devuelve una LISTA de valores y el operador IN.
-- Evidencia: docs/evidencias/06 (C5b). Con datos semilla salen las 10
--   categorias (cada usuario tiene una nota en la suya).
-- ---------------------------------------------------------------------------
SELECT ca.id_categoria, ca.nombre, ca.tipo
FROM CATEGORIA ca
WHERE ca.id_categoria IN
      (SELECT n.id_categoria FROM NOTA n)
ORDER BY ca.id_categoria;

-- ---------------------------------------------------------------------------
-- Consulta 08.3: Buscar cuenta por correo usando una subconsulta (unicidad)
-- Objetivo: Localizar un usuario por su correo sin escribir el correo en la
--   consulta (la subconsulta lo obtiene a partir del id).
-- Demuestra: La subconsulta usa la PK; la externa usa el indice UNICO
--   uq_usuario_correo (type=const, key_len=602; evidencia 05, Q2b).
-- ---------------------------------------------------------------------------
SELECT u.id_usuario, u.nombre
FROM USUARIO u
WHERE u.correo = (SELECT c.correo FROM USUARIO c WHERE c.id_usuario = 1);

-- =============================================================================
-- SECCION 09: CASE
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Consulta 09.1: Clasificacion de actividades por vencimiento
-- Objetivo: Etiquetar cada actividad como Terminada, Vencida, Vence hoy o
--   Vigente, sin modificar datos.
-- Demuestra: CASE con condiciones en orden: la primera que se cumple gana,
--   por eso una actividad Completada nunca aparece como Vencida.
-- Evidencia: docs/evidencias/06 (C6). Depende de CURDATE().
-- ---------------------------------------------------------------------------
SELECT id_actividad, titulo, estado, fecha_limite,
       CASE
         WHEN estado = 'Completada'    THEN 'Terminada'
         WHEN fecha_limite < CURDATE() THEN 'Vencida'
         WHEN fecha_limite = CURDATE() THEN 'Vence hoy'
         ELSE 'Vigente'
       END AS clasificacion
FROM ACTIVIDAD
ORDER BY clasificacion, fecha_limite;

-- =============================================================================
-- SECCION 10: UNION y UNION ALL
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Consulta 10.1: Todo lo vencido (actividades + proyectos apilados)
-- Objetivo: Una sola lista de compromisos atrasados, sea actividad o proyecto.
-- Demuestra: UNION ALL apila dos consultas con columnas equivalentes SIN
--   eliminar duplicados; la columna literal 'origen' distingue cada bloque.
-- Evidencia: docs/evidencias/06 (C7). Depende de CURDATE().
-- ---------------------------------------------------------------------------
SELECT a.id_usuario, 'ACTIVIDAD' AS origen, a.titulo AS elemento, a.fecha_limite AS fecha
FROM ACTIVIDAD a
WHERE a.estado <> 'Completada' AND a.fecha_limite < CURDATE()
UNION ALL
SELECT p.id_usuario, 'PROYECTO', p.nombre, p.fecha_fin
FROM PROYECTO p
WHERE p.estado <> 'Completado' AND p.fecha_fin < CURDATE()
ORDER BY fecha;

-- ---------------------------------------------------------------------------
-- Consulta 10.2: Conteo consolidado de las 12 tablas
-- Objetivo: Verificar la carga de datos completa en una sola consulta.
-- Demuestra: UNION ALL de 12 bloques con la misma estructura de columnas.
-- Nota: esta misma verificacion cierra database/KIRO_MariaDB.sql (fuente).
-- ---------------------------------------------------------------------------
SELECT 'USUARIO' AS tabla, COUNT(*) AS registros FROM USUARIO
UNION ALL SELECT 'REGISTRO_USUARIO', COUNT(*) FROM REGISTRO_USUARIO
UNION ALL SELECT 'INICIO_SESION',    COUNT(*) FROM INICIO_SESION
UNION ALL SELECT 'PERFIL_KIRO',      COUNT(*) FROM PERFIL_KIRO
UNION ALL SELECT 'CATEGORIA',        COUNT(*) FROM CATEGORIA
UNION ALL SELECT 'PROYECTO',         COUNT(*) FROM PROYECTO
UNION ALL SELECT 'ACTIVIDAD',        COUNT(*) FROM ACTIVIDAD
UNION ALL SELECT 'NOTA',             COUNT(*) FROM NOTA
UNION ALL SELECT 'RECURSO',          COUNT(*) FROM RECURSO
UNION ALL SELECT 'RECUERDO',         COUNT(*) FROM RECUERDO
UNION ALL SELECT 'CITA',             COUNT(*) FROM CITA
UNION ALL SELECT 'HISTORIAL_ACCION', COUNT(*) FROM HISTORIAL_ACCION;

-- =============================================================================
-- SECCION 11: COMPROBACION DE INTEGRIDAD REFERENCIAL
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Consulta 11.1: Filas huerfanas de ACTIVIDAD hacia USUARIO
-- Objetivo: Comprobar que toda actividad pertenece a un usuario existente.
-- Demuestra: LEFT JOIN ... IS NULL como detector de huerfanos.
--   Resultado esperado: 0 (la FK fk_actividad_usuario ya lo impide; la
--   consulta demuestra el metodo de verificacion, no reemplaza a la FK).
-- ---------------------------------------------------------------------------
SELECT COUNT(*) AS huerfanas
FROM ACTIVIDAD a
LEFT JOIN USUARIO u ON u.id_usuario = a.id_usuario
WHERE u.id_usuario IS NULL;

-- ---------------------------------------------------------------------------
-- Consulta 11.2: Filas huerfanas de NOTA hacia CATEGORIA (FK compuesta)
-- Objetivo: Comprobar la integridad de la FK compuesta (id_categoria,
--   id_usuario): la nota debe apuntar a una categoria DEL MISMO usuario.
-- Demuestra: verificacion con la FK compuesta completa (ambas columnas).
--   Resultado esperado: 0. Ignora intencionalmente las notas sin categoria.
-- ---------------------------------------------------------------------------
SELECT COUNT(*) AS huerfanas
FROM NOTA n
LEFT JOIN CATEGORIA c
  ON c.id_categoria = n.id_categoria
 AND c.id_usuario   = n.id_usuario
WHERE n.id_categoria IS NOT NULL AND c.id_categoria IS NULL;

-- ---------------------------------------------------------------------------
-- Consulta 11.3: Catalogo de las 14 claves foraneas del esquema
-- Objetivo: Listar las FK declaradas con su tabla y referencia.
-- Demuestra: Consulta del catalogo information_schema (solo lectura).
--   Evidencia completa: docs/evidencias/04_estructura_integridad.md.
-- Requiere: cuenta administradora o permiso de lectura del catalogo.
-- ---------------------------------------------------------------------------
SELECT CONSTRAINT_NAME, TABLE_NAME, REFERENCED_TABLE_NAME
FROM information_schema.REFERENTIAL_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'Kiro'
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- =============================================================================
-- SECCION 12: DEMOSTRACION DE VISTAS (4)
-- =============================================================================
-- Las vistas encapsulan consultas reutilizables; aqui se comprueba que
-- devuelven datos coherentes con las tablas base (evidencias 01 y 02).

-- ---------------------------------------------------------------------------
-- Consulta 12.1: vw_kiro_proximas_citas
-- Objetivo: Citas futuras no canceladas de cualquier usuario.
-- Demuestra: Vista con filtros (fecha futura + estado). El conteo depende
--   de la fecha de ejecucion (usa CURRENT_TIMESTAMP).
-- ---------------------------------------------------------------------------
SELECT COUNT(*) AS filas FROM vw_kiro_proximas_citas;

-- ---------------------------------------------------------------------------
-- Consulta 12.2: vw_kiro_actividades_pendientes
-- Objetivo: Actividades pendientes con su proyecto.
-- Demuestra: Vista con filtro de estado. Esperado: 4 filas.
-- ---------------------------------------------------------------------------
SELECT COUNT(*) AS filas FROM vw_kiro_actividades_pendientes;

-- ---------------------------------------------------------------------------
-- Consulta 12.3: vw_kiro_proyectos_activos
-- Objetivo: Proyectos en progreso con prioridad y fecha de fin.
-- Demuestra: Vista con filtro de estado. Esperado: 8 filas.
-- ---------------------------------------------------------------------------
SELECT COUNT(*) AS filas FROM vw_kiro_proyectos_activos;

-- ---------------------------------------------------------------------------
-- Consulta 12.4: vw_kiro_notas_categorias
-- Objetivo: Notas junto a su categoria (INNER JOIN encapsulado).
-- Demuestra: Vista que a su vez contiene un INNER JOIN. Esperado: 10 filas.
-- ---------------------------------------------------------------------------
SELECT COUNT(*) AS filas FROM vw_kiro_notas_categorias;

-- =============================================================================
-- SECCION 13: DEMOSTRACION DE FUNCIONES (5)
-- =============================================================================
-- Cada funcion se llama con un id de prueba (1). Los resultados concretos
-- dependen de los datos vigentes; lo demostrado es la llamada y su retorno.

-- ---------------------------------------------------------------------------
-- Consulta 13.1: fn_total_actividades_pendientes(p_id_usuario)
-- Objetivo: Total de actividades pendientes del usuario.
-- Demuestra: Funcion READS SQL DATA con SELECT COUNT(*), parametrizada.
-- ---------------------------------------------------------------------------
SELECT fn_total_actividades_pendientes(1) AS actividades_pendientes;

-- ---------------------------------------------------------------------------
-- Consulta 13.2: fn_total_proyectos_activos(p_id_usuario)
-- Objetivo: Total de proyectos no completados del usuario.
-- Demuestra: Funcion con filtro <> 'Completado'.
-- ---------------------------------------------------------------------------
SELECT fn_total_proyectos_activos(1) AS proyectos_activos;

-- ---------------------------------------------------------------------------
-- Consulta 13.3: fn_total_notas_usuario(p_id_usuario)
-- Objetivo: Total de notas del usuario.
-- Demuestra: Funcion de conteo simple.
-- ---------------------------------------------------------------------------
SELECT fn_total_notas_usuario(1) AS notas;

-- ---------------------------------------------------------------------------
-- Consulta 13.4: fn_total_recursos_usuario(p_id_usuario)
-- Objetivo: Total de recursos del usuario.
-- Demuestra: Funcion de conteo simple sobre RECURSO.
-- ---------------------------------------------------------------------------
SELECT fn_total_recursos_usuario(1) AS recursos;

-- ---------------------------------------------------------------------------
-- Consulta 13.5: fn_calcular_fecha_fin_cita(p_id_cita)
-- Objetivo: Fecha y hora de fin de una cita (inicio + duracion).
-- Demuestra: Funcion con DATE_ADD e INTERVAL; util para la validacion de
--   solapamientos del SP sp_registrar_cita_segura.
-- ---------------------------------------------------------------------------
SELECT fn_calcular_fecha_fin_cita(1) AS fecha_fin_cita;

-- =============================================================================
-- SECCION 14: DEMOSTRACION DE PROCEDIMIENTO DE SOLO LECTURA (CALL)
-- =============================================================================
-- ATENCION: esta seccion queda COMENTADA por defecto.
--   - El SP sp_resumir_actividades_usuario SOLO LEE datos (cursor + SELECT):
--     su ejecucion no modifica nada y fue verificada (retorna el resumen por
--     estado del usuario, evidencia 02).
--   - Se deja comentada para que este archivo cumpla estrictamente la regla
--     de "solo SELECT" si se ejecuta completo de una vez.
--   - El otro SP (sp_registrar_cita_segura) SI ESCRIBE datos: su demostracion
--     NO pertenece a este archivo; se propondria por separado si se requiere.
--
-- Descomentar para demostrar el cursor:
-- CALL sp_resumir_actividades_usuario(1);
-- =============================================================================

-- -----------------------------------------------------------------------------
-- FIN DE QUERY_02. Ninguna consulta de este archivo modifica la base de datos.
-- -----------------------------------------------------------------------------
