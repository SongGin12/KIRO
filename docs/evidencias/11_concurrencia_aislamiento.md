# Evidencia 11 - Concurrencia, bloqueos y niveles de aislamiento

- Servidor: MariaDB 10.4.32-MariaDB
- Fecha de la prueba: 2026-11-16
- Scripts reproducibles: `database/consultas/QUERY_05_concurrencia/` (11 archivos: construccion, 5 experimentos con sesiones A y B, limpieza)
- Metodo: cada sesion (A y B) ejecuto su propio script en una CONEXION independiente de `mysql.exe` (verificado con `CONNECTION_ID()` distinto en cada salida: 314/315, 316/317, 319/320, 322/323, 325/326). Las dos sesiones de cada experimento se lanzaron SIMULTANEAMENTE como procesos en segundo plano; la alineacion temporal la fijan los `SELECT SLEEP(n)` internos y TODA lectura relevante lleva sello `NOW(6)` para reconstruir la cronologia real.
- Alcance: TODAS las escrituras ocurrieron en la base de laboratorio `kiro_labo_concurrencia` (tabla `asiento`, InnoDB). Ninguna tabla real de `Kiro` fue escrita (guardias de CHECKSUM y conteos identicas antes y despues). No se ejecuto ningun `SET GLOBAL`: solo `SET SESSION`.

## 1. Objetivo y relacion con RN-07 y la seccion 7.5 del plan

Demostrar experimentalmente los comportamientos de concurrencia del contenido de la asignatura: prevencion de lecturas sucias con `REPEATABLE READ`, existencia de lecturas sucias con `READ UNCOMMITTED`, posibilidad de lecturas no repetibles con `READ COMMITTED` y su prevencion con el snapshot de `REPEATABLE READ`, y el bloqueo de fila de InnoDB con espera de la segunda transaccion hasta que la primera confirma.

**El plan no queda modificado por esta evidencia.** La estrategia de concurrencia para citas (RN-07, seccion 7.5) sigue PENDIENTE de especificacion y prueba; esta evidencia no cierra esa decision. Su aporte es observar, en el servidor real, los mecanismos de aislamiento y bloqueo sobre los que esa estrategia futura se apoyara (ver seccion 9).

## 2. Configuracion observada del servidor (solo lectura)

| Variable | Valor observado |
|---|---|
| Version | 10.4.32-MariaDB |
| Aislamiento predeterminado (`@@tx_isolation`) | REPEATABLE-READ |
| Nombre de la variable de aislamiento | `tx_isolation` (MariaDB). NOTA tecnica: la variable `transaction_isolation` de MySQL 8 NO existe en este servidor (verificado: error 1193 al consultarla) |
| `autocommit` | 1 |
| `innodb_lock_wait_timeout` | 50 (global; en E3 se ajusto a 30 SOLO por sesion) |
| `innodb_deadlock_detect` | 1 (activo) |

Motor de las 12 tablas de `Kiro`: InnoDB (12/12). Sin transacciones abiertas al inicio (`information_schema.INNODB_TRX` = 0).

## 3. Diseno del laboratorio

- Base `kiro_labo_concurrencia` creada para esta ejecucion (charset utf8mb4); guardia previa: no existia.
- Tabla `asiento` (InnoDB): `id INT PK, valor INT, etiqueta VARCHAR(60)`, una fila semilla `(1, 10, 'semilla')`. La tabla simula un recurso unico reservable (analogia directa con la reserva de una cita: un mismo registro que dos sesiones leen, modifican y bloquean).
- Cada experimento = par de scripts (sesion A y sesion B) ejecutados en conexiones independientes y simultaneas. Entre experimentos, la fila semilla se restauro a `(10, 'semilla')` con un UPDATE de autocommit, solo en la tabla de laboratorio.
- Ninguna transaccion queda abierta: cada script termina en `COMMIT` o `ROLLBACK` y un `FIN_A`/`FIN_B` marca su terminacion completa.

## 4. Desarrollo y resultados por experimento

### 4.1. E1a - Lectura sucia y su prevencion (B con REPEATABLE READ)

**Que ejecuta cada sesion:** A abre una transaccion, cambia la fila a 11 ('A_sin_confirmar') sin confirmar, espera 12 s y hace ROLLBACK. B (REPEATABLE-READ) lee en t~4 (cambio de A en vuelo) y en t~16 (tras el rollback).

**Cronologia real (NOW(6)):**

| Evento | Sesion | Marca temporal | Valor leido | Etiqueta |
|---|---|---|---|---|
| Inicio A (conexion 314) | A | 2026-11-16 22:09:30.724517 | - | - |
| UPDATE sin confirmar de A | A | 22:09:30.726895 | 11 (propio) | A_sin_confirmar |
| Lectura 1 de B (conexion 315) | B | 22:09:34.802610 | **10** | semilla |
| ROLLBACK de A | A | 22:09:42.741932 | 10 | semilla |
| Lectura 2 de B | B | 22:09:46.812634 | **10** | semilla |

**Verificacion de cronologia:** la lectura 1 de B (34.802) ocurrio dentro de la transaccion abierta de A (30.726 -> 42.741), con el cambio sin confirmar en vuelo; la lectura 2 (46.812) ocurrio tras el ROLLBACK. Ambas lecturas: **10**.

**Resultado observado = esperado: B NO vio la lectura sucia (10 en ambas lecturas).** InnoDB con REPEATABLE READ previene la lectura de datos no confirmados.

### 4.2. E1b - Lectura sucia con READ UNCOMMITTED

**Que ejecuta cada sesion:** identico a E1a en la parte de A (update sin confirmar a t~0, ROLLBACK a t~10.5); B fija `SET SESSION tx_isolation = 'READ-UNCOMMITTED'` y lee en t~4 y t~14.

**Cronologia real (NOW(6)):**

| Evento | Sesion | Marca temporal | Valor leido | Etiqueta |
|---|---|---|---|---|
| Inicio A (conexion 316) | A | 2026-11-16 22:09:57.643098 | - | - |
| UPDATE sin confirmar de A | A | 22:09:57.643850 | 11 (propio) | A_sin_confirmar |
| Lectura 1 de B (conexion 317) | B | 22:10:01.743745 | **11** | A_sin_confirmar |
| ROLLBACK de A | A | 22:10:07.657383 | 10 | semilla |
| Lectura 2 de B | B | 22:10:11.759180 | **10** | semilla |

**Verificacion de cronologia:** la lectura 1 (01.743) cayo dentro de la transaccion abierta de A (57.643 -> 07.657); la lectura 2 (11.759) fue posterior al ROLLBACK.

**Resultado observado = esperado: B SI vio el valor no confirmado (11, 'A_sin_confirmar') y luego volvio a ver 10 tras el rollback.** La lectura sucia existe y el nivel de aislamiento es lo que la permite (READ UNCOMMITTED) o la previene (E1a). El valor sucio nunca fue un dato confirmado: desaparecio con el ROLLBACK.

### 4.3. E2a - Lectura no repetible con READ COMMITTED

**Que ejecuta cada sesion:** B (READ-COMMITTED) abre una transaccion y lee la fila (10); 5 s despues A actualiza a 20 y CONFIRMA, con la transaccion de B todavia abierta; B vuelve a leer 10 s mas tarde y cierra con COMMIT.

**Cronologia real (NOW(6)):**

| Evento | Sesion | Marca temporal | Valor leido |
|---|---|---|---|
| Inicio B (conexion 320) y lectura 1 | B | 2026-11-16 22:10:23.110831 | **10** (semilla) |
| COMMIT de A (conexion 319): fila a 20 | A | 22:10:28.036899 | - |
| Lectura 2 de B (misma transaccion) | B | 22:10:38.124774 | **20** (A_confirmada) |
| COMMIT de B | B | 22:10:38.125359 | - |

**Verificacion de cronologia:** el COMMIT de A (28.036) ocurrio entre la lectura 1 (23.110) y la lectura 2 (38.124) de B, con la transaccion de B abierta todo el tiempo.

**Resultado observado = esperado: 10 -> 20 dentro de una misma transaccion (LECTURA NO REPETIBLE posible).** Con READ COMMITTED, cada lectura ve lo ultimo confirmado, incluso dentro de una misma transaccion.

### 4.4. E2b - Prevencion con REPEATABLE READ (snapshot)

**Que ejecuta cada sesion:** identico a E2a pero B con REPEATABLE-READ (nivel predeterminado del servidor). La fila se restauro a 10 antes del experimento.

**Cronologia real (NOW(6)):**

| Evento | Sesion | Marca temporal | Valor leido |
|---|---|---|---|
| Inicio B (conexion 323) y lectura 1 | B | 2026-11-16 22:10:47.583027 | **10** (semilla) |
| COMMIT de A (conexion 322): fila a 20 | A | 22:10:52.515800 | - |
| Lectura 2 de B (misma transaccion) | B | 22:11:02.588936 | **10** (semilla) |
| COMMIT de B | B | 22:11:02.589361 | - |

**Verificacion de cronologia:** igual estructura temporal que E2a (COMMIT de A en 52.515, dentro de la transaccion de B).

**Resultado observado = esperado: 10 -> 10 dentro de la misma transaccion.** Con REPEATABLE READ, la primera lectura fija un snapshot consistente: la misma consulta devuelve el MISMO valor aunque otra sesion confirme cambios en el interin (lectura no repetible PREVENIDA).

### 4.5. E3 - Bloqueo de fila InnoDB y espera resuelta por COMMIT

**Que ejecuta cada sesion:** A abre una transaccion y ACTUALIZA la fila (10 -> 11, 'A_bloqueo'): InnoDB toma un bloqueo exclusivo (X) sobre esa fila y lo retiene 10 s. B (REPEATABLE-READ, `innodb_lock_wait_timeout` por sesion = 30) espera 3 s e intenta ACTUALIZAR la misma fila (+10): queda EN ESPERA hasta que A confirma.

**Cronologia real (NOW(6)):**

| Evento | Sesion | Marca temporal |
|---|---|---|
| Inicio A (conexion 325) | A | 2026-11-16 22:11:09.950284 |
| UPDATE de A (10 -> 11; toma el bloqueo X) | A | 22:11:09.952743 |
| Inicio B (conexion 326) | B | 22:11:10.043033 |
| B listo para actualizar (t_antes_update_B) | B | 22:11:13.058664 |
| COMMIT de A (libera el bloqueo) | A | 22:11:19.965090 |
| UPDATE de B completado (t_despues_update_B) | B | 22:11:19.964971 |
| Valor leido por B tras su UPDATE | B | **21** (B_post_bloqueo) |
| COMMIT de B | B | 22:11:19.965741 |

**Tiempo real de espera de B:** 19.964971 - 13.058664 = **6.906307 segundos** (espero el bloqueo de fila de A, que se libero con su COMMIT; el UPDATE de B avanzo en el instante de la liberacion, sin timeout ni error).

**Resultado observado = esperado: valor final 21** (10 semilla + 1 de A + 10 de B), con serializacion efectiva de las dos escrituras sobre la misma fila. La lectura de B tras su UPDATE muestra 21 y 'B_post_bloqueo' (escrituras aplicadas en orden: primero A, despues B).

## 5. SERIALIZABLE (explicacion conceptual, sin ejecutar)

`SERIALIZABLE` es el nivel de aislamiento mas estricto: en InnoDB equivale a REPEATABLE READ con una regla adicional: todas las lecturas simples (`SELECT` sin `FOR UPDATE` ni `FOR SHARE`) toman implicitamente bloqueos compartidos (S) que se retienen hasta el fin de la transaccion. Efecto: dos transacciones no pueden leer la misma fila mientras otra la modifica, lo que hace las operaciones efectivamente secuenciales (serializables).

Costo: menos concurrencia (las lecturas tambien bloquean), mas riesgo de esperas y deadlocks. Es el nivel natural para exigir la regla "no se puede reservar un recurso ya reservado" (como una cita que no debe solaparse), pero su costo suele hacer preferible una combinacion de REPEATABLE READ + bloqueos explicitos en los puntos criticos (`SELECT ... FOR UPDATE`).

## 6. SELECT ... FOR UPDATE como patron para la futura especificacion de RN-07

El patron que la literatura y esta evidencia apuntan para la comprobacion de solapamientos de citas es: dentro de una transaccion, **bloquear las filas de citas del usuario que podrian solaparse con `SELECT ... FOR UPDATE`** ANTES de comprobar el intervalo e insertar; asi, dos inserciones concurrentes de la misma agenda se serializan (la segunda espera el bloqueo, y al avanzar la primera ya esta confirmada y visible para la comprobacion). NOTA: este patron NO se implementa en esta etapa: el SP `sp_registrar_cita_segura` existente no se modifica; el diseno concreto (incluyendo que indices usar para el bloqueo) sigue siendo la decision pendiente de la seccion 7.5 del plan.

## 7. Limpieza y comprobacion de integridad de KIRO

| Comprobacion | Inicial | Final | Resultado |
|---|---|---|---|
| Transacciones abiertas (`INNODB_TRX`) | 0 | 0 | sin pendientes |
| Sesiones del laboratorio (conexiones 314-326) | - | 0 | todas finalizadas |
| Base `kiro_labo_concurrencia` | no existia | **eliminada** (0 restos) | limpieza completa |
| CHECKSUM de las 12 tablas de `Kiro` | baseline historico | **identico** (usuario 882274266, cita 1030271630, etc.) | base intacta |
| Conteo total de registros de `Kiro` | 122 | 122 | intacto |
| Objetos de `Kiro` (vistas/funciones/SP/triggers) | 4/5/2/2 | 4/5/2/2 | intacto |
| Configuracion global del servidor | REPEATABLE-READ, timeout 50 | REPEATABLE-READ, timeout 50 | sin cambios (solo `SET SESSION`) |

## 8. Conclusiones y limitaciones

**Conclusiones demostradas (resultados observados, no supuestos):**

1. InnoDB en MariaDB 10.4.32 previene lecturas sucias con REPEATABLE READ (E1a: 10 y 10) y las permite con READ UNCOMMITTED (E1b: 11 y luego 10): el nivel de aislamiento es el mecanismo que controla el fenomeno.
2. READ COMMITTED permite lecturas no repetibles (E2a: 10 -> 20 en una misma transaccion); REPEATABLE READ las previene con su snapshot (E2b: 10 -> 10).
3. El bloqueo de fila de InnoDB serializa escrituras concurrentes sobre la misma fila: B espero 6.906307 s reales hasta el COMMIT de A y aplico su cambio despues (valor final 21).
4. Todo se realizo sin `SET GLOBAL`, sin tocar tablas reales y sin dejar transacciones abiertas ni objetos de laboratorio.

**Limitaciones:**

1. La cronologia depende de los retardos `SLEEP` internos de cada script y del arranque casi simultaneo de dos procesos; los margenes usados (3-5 s entre hitos) y los sellos `NOW(6)` hacen la reconstruccion verificable, pero el experimento es de laboratorio, no una medicion de rendimiento.
2. No se ejecuto SERIALIZABLE ni la variante de timeout de bloqueo (error 1205), por decision de alcance (no provocar errores intencionales).
3. No se probaron deadlocks reales (la deteccion esta activa por configuracion, pero no se genero ninguno).
4. La concurrencia de KIRO en produccion (el SP de citas) NO se modifico ni se probo aqui: RN-07 sigue pendiente de especificacion en el plan; esta evidencia documenta los mecanismos base para ese diseno.
5. La tabla de laboratorio tenia una sola fila: el volumen no representa carga real.
