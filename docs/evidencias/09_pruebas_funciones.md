# Evidencia 09 - Pruebas de las funciones almacenadas (5)

- Servidor: MariaDB 10.4.32-MariaDB, base `Kiro`
- Fecha de la prueba: 2026-11-16
- Metodo: cada funcion se contrasta contra el SQL equivalente de solo lectura (el `SELECT COUNT(*)` o el `DATE_ADD` que implementa), con columna `coincide` calculada dentro del servidor. No se modifico ningun dato; la guardia final de `CHECKSUM TABLE` confirma que la base quedo intacta.
- Estructura de las pruebas: separadas por el parametro de cada funcion.
  - **Grupo 1:** las 4 funciones que reciben `id_usuario`.
  - **Grupo 2:** `fn_calcular_fecha_fin_cita`, que recibe `id_cita`.
  - El identificador **11 corresponde a una CITA** (creada por `sp_registrar_cita_segura` en el laboratorio de la evidencia 02) y se usa solo en el Grupo 2. Para poder usarlo tambien en el Grupo 1 se comprobó POR SEPARADO que no existe un usuario con ese identificador (seccion 1.c).

## 1. Grupo 1 - Funciones con parametro id_usuario

Funciones: `fn_total_actividades_pendientes`, `fn_total_proyectos_activos`, `fn_total_notas_usuario`, `fn_total_recursos_usuario`. Todas `READS SQL DATA` con `SELECT COUNT(*) ... INTO` y `RETURN`.

### 1.a. Usuario id 1 (semilla existente): valor esperado vs. observado

| Funcion | SQL equivalente (esperado) | Retorno observado | coincide |
|---|---|---|---|
| `fn_total_actividades_pendientes(1)` | `COUNT(*) FROM ACTIVIDAD WHERE id_usuario=1 AND estado='Pendiente'` = **0** | **0** | si (1) |
| `fn_total_proyectos_activos(1)` | `COUNT(*) FROM PROYECTO WHERE id_usuario=1 AND estado<>'Completado'` = **1** | **1** | si (1) |
| `fn_total_notas_usuario(1)` | `COUNT(*) FROM NOTA WHERE id_usuario=1` = **1** | **1** | si (1) |
| `fn_total_recursos_usuario(1)` | `COUNT(*) FROM RECURSO WHERE id_usuario=1` = **1** | **1** | si (1) |

Resultado: **4/4 funciones coinciden** con su SQL equivalente para el usuario 1.

### 1.b. Caso de borde: id inexistente (9999)

Retorno real de las cuatro funciones con `p_id_usuario = 9999` (usuario que no existe):

| fn_total_actividades_pendientes | fn_total_proyectos_activos | fn_total_notas_usuario | fn_total_recursos_usuario |
|---|---|---|---|
| 0 | 0 | 0 | 0 |

Comportamiento: todas retornan **0** (`COUNT(*)` de un conjunto vacio), sin error. Correcto para una funcion de conteo.

### 1.c. Caso id 11 (uso separado y verificado)

El id 11 pertenece al dominio de CITA (seccion 2). Antes de usarlo en funciones de usuario se verifico por separado, con lectura directa, que **no existe** un `USUARIO` con `id_usuario = 11`:

```sql
SELECT COUNT(*) FROM USUARIO WHERE id_usuario = 11;   -- Resultado real: 0
```

Con esa comprobacion registrada, las cuatro funciones con `p_id_usuario = 11` retornaron **0 / 0 / 0 / 0**, coherente con la inexistencia del usuario. Este caso documenta el mismo comportamiento de borde que 1.b y evita una conclusion equivocada (el 0 no significa "usuario sin registros", sino "usuario inexistente").

## 2. Grupo 2 - fn_calcular_fecha_fin_cita (parametro id_cita)

Funcion: `fn_calcular_fecha_fin_cita(p_id_cita)` -> `DATE_ADD(fecha_inicio, INTERVAL duracion_minutos MINUTE)` de la cita.

### 2.a. Cita id 1 (semilla existente)

| | Valor real |
|---|---|
| SQL equivalente (esperado) | `2026-11-12 10:00:00` |
| Retorno observado | `2026-11-12 10:00:00` |
| coincide | si (1) |

### 2.b. Cita id 11 (creada por el SP transaccional; dominio correcto de esta funcion)

| | Valor real |
|---|---|
| SQL equivalente (esperado) | `2026-11-22 10:45:00` |
| Retorno observado | `2026-11-22 10:45:00` |
| coincide | si (1) |

Esta prueba es relevante porque la cita 11 fue insertada por `sp_registrar_cita_segura` durante el laboratorio de objetos: la funcion calcula correctamente la hora de fin sobre un registro producido por la ruta transaccional.

### 2.c. Caso de borde: id_cita inexistente (9999)

```sql
SELECT fn_calcular_fecha_fin_cita(9999) IS NULL;   -- Resultado real: 1 (true)
```

Comportamiento: con una cita inexistente la funcion retorna **NULL** (el `SELECT ... INTO` no encuentra fila y la variable `DATETIME` queda en NULL), sin error. Es un comportamiento distinto al de las funciones de conteo (que retornan 0) y conviene conocerlo para el consumo desde la aplicacion.

## 3. Observacion honesta: comentario del script de exportacion

El comentario de cabecera de `fn_total_actividades_pendientes` en `database/objetos/02_funciones.sql` dice "Total de actividades pendientes **o en progreso**", pero la implementacion (y el objeto real del servidor) cuenta **solo** `estado = 'Pendiente'`. La propia prueba lo demuestra: el usuario 1 tiene exactamente 1 actividad, con estado `En progreso` (lectura real: `id_actividad 1`, `Preparar informe`, `En progreso`, limite `2026-11-15`), y la funcion retorno **0**, no 1.

- La implementacion es consistente con la vista `vw_kiro_actividades_pendientes` (tambien filtra `estado = 'Pendiente'`).
- El objeto en el servidor no lleva ese comentario: el texto inexacto esta unicamente en el script de exportacion de `database/objetos/`.
- Este archivo no se modifica en esta etapa; la correccion del comentario (si se aprueba) es una edicion puntual posterior del script, no del objeto.

## 4. Cobertura y resultados globales

| Funcion | Parametro | Casos probados | coincide con SQL equivalente |
|---|---|---|---|
| fn_total_actividades_pendientes | id_usuario | id 1; id 9999; id 11 (verificado) | si |
| fn_total_proyectos_activos | id_usuario | id 1; id 9999; id 11 (verificado) | si |
| fn_total_notas_usuario | id_usuario | id 1; id 9999; id 11 (verificado) | si |
| fn_total_recursos_usuario | id_usuario | id 1; id 9999; id 11 (verificado) | si |
| fn_calcular_fecha_fin_cita | id_cita | id 1; id 11; id 9999 | si |

**Resultado global: 5/5 funciones correctas** en su caso principal, con comportamiento documentado en los casos de borde (0 para conteos con id inexistente, NULL para el calculo de fecha con id inexistente).

## 5. Guardia final de integridad

`CHECKSUM TABLE` de las 12 tablas reales al terminar las pruebas: identico al baseline historico (usuario 882274266, cita 1030271630, y los 12 valores registrados en la evidencia 08, seccion 3). Las pruebas fueron exclusivamente de lectura.

## 6. Conclusiones y limitaciones

**Conclusiones:**

1. Las 5 funciones almacenadas retornan exactamente el mismo valor que su SQL equivalente, verificado caso por caso dentro del servidor.
2. Los casos de borde estan documentados con su comportamiento real (0 vs. NULL segun el tipo de funcion).
3. La prueba con la cita 11 conecta la cadena completa del laboratorio: SP transaccional (crea la cita) -> funcion (calcula su hora de fin).

**Limitaciones:**

1. Los valores concretos dependen de los datos vigentes (semilla + registros de laboratorio); con otros datos los numeros cambian, pero el metodo de contraste esperado/observado se mantiene.
2. No se probaron las funciones bajo el usuario de aplicacion `kiro_app` (que no tiene permiso `EXECUTE` por diseno de minimo privilegio; las pruebas requieren cuenta administradora por el `DEFINER`).
3. No se prueba el consumo de las funciones desde la aplicacion PHP: la etapa actual de la aplicacion consulta tablas, no funciones; su ampliacion es un paso previsto en el README.
