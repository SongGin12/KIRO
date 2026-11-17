# Evidencia 08 - Transacciones: START TRANSACTION, SAVEPOINT, ROLLBACK TO SAVEPOINT y COMMIT

- Servidor: MariaDB 10.4.32-MariaDB, base `Kiro`
- Fecha de la prueba: 2026-11-16
- Script reproducible: `database/consultas/QUERY_03_transacciones.sql` (ejecutado de punta a punta, exit 0, con `mysql.exe --default-character-set=utf8mb4 -t`)
- Metodo: la demostracion se realizo EXCLUSIVAMENTE sobre una tabla `TEMPORARY` de laboratorio (`tmp_labo_savepoint`, ENGINE=InnoDB). Ninguna tabla real de Kiro fue escrita; las guardias de `CHECKSUM TABLE` y conteos antes y despues lo demuestran. No se crearon procedimientos nuevos y no se tocaron las bases de restauracion.
- Aclaracion honesta sobre el COMMIT: el COMMIT consolida el registro **vigente dentro de la sesion**. La tabla es temporal: al cerrar la conexion, la tabla y su contenido desaparecen. En la seccion 4 se verifica que no queda ningun rastro persistente.

## 1. Objetivo academico

Cubrir el contenido de transacciones de la asignatura demostrando, con resultados reales:

1. `START TRANSACTION` y `COMMIT`: una unidad de trabajo se confirma de forma atomica.
2. `SAVEPOINT` y `ROLLBACK TO SAVEPOINT`: se deshace SOLO lo posterior a un punto intermedio, sin cerrar la transaccion.
3. `ROLLBACK` total: se descarta toda la transaccion abierta.

Este ultimo matiz (deshacer parcial vs. total) complementa al SP `sp_registrar_cita_segura`, que ya demostraba la transaccion completa con `START TRANSACTION` / `COMMIT` / `ROLLBACK` (evidencia 02; su registro de laboratorio es la cita id 11).

## 2. Aislamiento del laboratorio

La tabla temporal vive solo en la sesion que la crea:

- Otras sesiones no la ven (no aparece en `information_schema.TABLES` para nadie mas).
- No altera la estructura ni los datos de ninguna tabla real.
- Desaparece automaticamente al cerrar la conexion: no hay que borrar nada.

El `CREATE TEMPORARY TABLE` se ejecuto antes del `START TRANSACTION` (buena practica: el DDL queda fuera de la unidad de trabajo).

## 3. Guardias previas (seccion 0 del script)

`CHECKSUM TABLE` de las 12 tablas reales y conteo total, medidos antes de la demostracion. Valores observados (identicos al baseline historico de la base, registrado desde la evidencia 07):

| Tabla | Checksum | | Tabla | Checksum |
|---|---|---|---|---|
| usuario | 882274266 | | nota | 1901855308 |
| registro_usuario | 3702753872 | | recurso | 2631569251 |
| perfil_kiro | 2789492068 | | actividad | 2584779342 |
| inicio_sesion | 3551093410 | | cita | 1030271630 |
| categoria | 1926394981 | | recuerdo | 4189147891 |
| proyecto | 1581122082 | | historial_accion | 225788971 |

Total de registros de las tablas reales: **122**.

## 4. Escenario A: SAVEPOINT + ROLLBACK TO SAVEPOINT + COMMIT (resultados reales)

Paso a paso ejecutado sobre `tmp_labo_savepoint` (columna de la izquierda: operacion; derecha: verificacion real capturada):

| Paso | Operacion SQL | Verificacion ejecutada | Resultado real |
|---|---|---|---|
| (a) | `START TRANSACTION` | — | (transaccion abierta) |
| (b) | `INSERT 'registro_persistente'` | `SELECT COUNT(*)` | **1** fila |
| (c) | `SAVEPOINT sp_despues_del_primero` | — | (punto creado) |
| (d) | `INSERT 'registro_a_descartar'` | `SELECT COUNT(*)` | **2** filas |
| (e) | `ROLLBACK TO SAVEPOINT sp_despues_del_primero` | `SELECT COUNT(*)` | **1** fila (solo se deshizo el INSERT del paso d; la transaccion siguio abierta) |
| (f) | `COMMIT` | — | (transaccion confirmada) |
| Final | `SELECT id, etiqueta` | — | **1 fila: `registro_persistente`** |

Lo que demuestra: `ROLLBACK TO SAVEPOINT` deshace parcialmente (2 -> 1) sin cerrar la transaccion, y el `COMMIT` posterior consolida lo vigente al punto de control. El registro queda vigente **dentro de la sesion**: al terminar la sesion del cliente, la tabla temporal y su contenido desaparecen.

## 5. Escenario B: ROLLBACK total (resultados reales)

| Paso | Operacion SQL | Verificacion ejecutada | Resultado real |
|---|---|---|---|
| 1 | `START TRANSACTION` | — | (transaccion abierta) |
| 2 | `INSERT 'registro_de_transaccion_descartada'` | `SELECT COUNT(*)` | **2** filas |
| 3 | `ROLLBACK` | — | (transaccion cerrada sin cambios) |
| 4 | `SELECT COUNT(*)` | — | **1** fila (el insert de B no persistio) |

Estado final dentro de la sesion: solo la fila `registro_persistente` (id 1). Lo que demuestra: un `ROLLBACK` total descarta toda la transaccion, a diferencia del deshacer parcial del escenario A.

## 6. Verificacion de que no queda rastro (sesion nueva)

Tras cerrar la sesion de la demo, en una conexion nueva (sin generar errores, consultando el catalogo):

```sql
SELECT COUNT(*) FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'Kiro' AND TABLE_NAME = 'tmp_labo_savepoint';
```

Resultado real: **0**. La tabla temporal no existe fuera de la sesion que la creo. El inventario de la base se mantiene en 12 tablas base.

## 7. Guardias posteriores (seccion 5 del script)

`CHECKSUM TABLE` de las 12 tablas reales y conteo total, medidos al final del script: **identicos** a la seccion 0 y al baseline historico (los 12 valores de la seccion 3). Total de registros: **122**. La base `Kiro` no fue modificada.

## 8. Relacion con el SP transaccional de KIRO

`sp_registrar_cita_segura` usa la transaccion completa (`START TRANSACTION`, `COMMIT`, `ROLLBACK` en un `EXIT HANDLER`) y no necesita savepoints: sus validaciones (`SIGNAL`) se evaluan antes del unico `INSERT`, por lo que el rollback siempre deshace todo. Un savepoint seria util si el SP tuviera varios pasos de escritura y quisiera descartar solo el ultimo; hoy el diseno actual no lo requiere, y esta evidencia cubre la construccion a nivel de SQL puro sin modificar el SP.

## 9. Conclusiones y limitaciones

**Conclusiones:**

1. La base `Kiro` (MariaDB 10.4.32) soporta y ejecuta correctamente `START TRANSACTION`, `SAVEPOINT`, `ROLLBACK TO SAVEPOINT`, `ROLLBACK` y `COMMIT`.
2. El deshacer parcial (`ROLLBACK TO SAVEPOINT`) difiere del deshacer total: conserva la transaccion abierta y solo cancela lo posterior al punto (verificado con conteos 1 -> 2 -> 1 -> COMMIT).
3. La transaccion se aislo completamente del esquema real mediante una tabla temporal de laboratorio, verificada con checksums, conteos y catalogo (sin rastro persistente).

**Limitaciones:**

1. La demostracion usa una tabla temporal y no una tabla real del esquema, por decision de aislamiento; el comportamiento transaccional de InnoDB es el mismo, pero el volumen es minimo (1-2 filas de laboratorio).
2. El registro conservado tras el COMMIT vive solo durante la sesion: es el comportamiento correcto de una tabla temporal y no un efecto de la transaccion.
3. Los savepoints no se probaron dentro de un SP almacenado; el SP existente no los requiere (seccion 8) y no se crearon objetos nuevos.
4. La concurrencia y los niveles de aislamiento (`REPEATABLE READ`, bloqueos) NO estan cubiertos en esta evidencia: quedan pendientes como contenido propio de la asignatura.
