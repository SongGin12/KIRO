# Plan de implementación de la base de datos — KIRO

**Proyecto:** KIRO  
**Asignatura:** Bases de Datos II  
**Institución:** Universidad de Los Andes (Unandes)  
**Documento:** Plan técnico de la base de datos en MariaDB 10.4.32  
**Fecha:** 11 de noviembre de 2026  
**Estado:** Plan técnico en revisión; implementación inicial de la base de datos realizada en MariaDB 10.4.32

**Fuentes de referencia:**

- `README.md` del repositorio.
- `docs/diagrama-er-kiro.png` (DER original de 12 entidades).
- Decisiones aprobadas para la planificación de la base de datos.

> **Alcance del documento.** Este plan describe el modelo lógico y las decisiones técnicas de la base de datos. No contiene el script ejecutable ni modifica el DER: la implementación inicial ya se realizó en MariaDB 10.4.32 y su script canónico es `database/KIRO_MariaDB.sql`. Las decisiones pendientes de la sección 7 siguen abiertas y no quedaron aprobadas por el hecho de haberse ejecutado el esquema.

---

## Leyenda de clasificación

| Etiqueta | Significado |
|---|---|
| **Hecho** | Dato verificable en el repositorio, el README o el DER. |
| **Decisión aprobada** | Criterio autorizado para incorporar en el plan. |
| **Recomendación** | Propuesta técnica que aún requiere validación o aprobación. |
| **Pendiente** | Decisión que no debe cerrarse sin revisar los requisitos. |
| **Convención provisional** | Valor de trabajo usado en un borrador que no está aprobado y no debe tratarse como definitivo. |

---

## 1. Propósito y alcance

### 1.1. Propósito

Definir el plan técnico para implementar en MariaDB 10.4.32 la base de datos de KIRO, respetando las 12 entidades del DER original, la arquitectura web del proyecto y las reglas de negocio documentadas en el README.

### 1.2. Alcance

Incluye:

- Inventario de entidades, atributos y tipos.
- Relaciones y cardinalidades.
- Análisis de normalización y redundancias.
- Identificación de problemas y soluciones aprobadas.
- Claves, restricciones e índices.
- Orden de creación de tablas.
- Plan de pruebas y validación.
- Matriz de trazabilidad con las reglas de negocio.
- Checklist previo a la implementación.

No incluye:

- La creación de tablas como parte de este documento; esa creación ya se ejecutó mediante `database/KIRO_MariaDB.sql`.
- El script SQL canónico dentro del plan; vive en `database/KIRO_MariaDB.sql`.
- Vistas, procedimientos, funciones o triggers implementados.
- Modificación del DER.
- Cambios en el README u otros documentos.
- Cambios en Git.

### 1.3. Principios del plan

1. **No se agregan ni eliminan entidades.** Se conservan las 12 entidades oficiales.
2. **Los atributos adicionales están identificados y justificados.** Solo se incorporan los aprobados.
3. **La integridad se protege en la base de datos cuando es posible.** Cuando no lo es, se define una validación controlada en la aplicación.
4. **La auditoría es parte del diseño, no un añadido posterior.**
5. **Las decisiones pendientes no se cierran por conveniencia técnica.**

---

## 2. Arquitectura tecnológica y estado actual

### 2.1. Hechos del repositorio

- El repositorio contiene `README.md`, `docs/diagrama-er-kiro.png`, este documento, el script canónico `database/KIRO_MariaDB.sql` y el borrador anterior `database/kiro_schema_draft.sql`.
- No existen todavía carpetas de aplicación, código PHP ni frontend. El único script de base de datos vigente es `database/KIRO_MariaDB.sql`; el borrador no está autorizado para ejecutarse.
- El README define KIRO como una aplicación web.
- El stack previsto es HTML5, CSS3, JavaScript, Bootstrap 5 y SVG en el frontend; PHP 8.x y PDO en el backend.
- **Entorno de base de datos confirmado:** MariaDB 10.4.32 con motor InnoDB. El servidor se administra desde MySQL Workbench, que actúa como cliente.
- La versión publicada se alojará en una infraestructura externa compatible con PHP y MariaDB; el proveedor no está definido.
- El desarrollo y las pruebas iniciales pueden realizarse en un entorno local.
- La base `Kiro` fue creada en MariaDB 10.4.32 con las 12 tablas, 12 claves primarias, 14 claves foráneas, 19 índices secundarios y 120 registros de prueba (10 por tabla).
- El análisis de índices con `EXPLAIN` sobre `Kiro` sigue pendiente; la práctica realizada en `db_ecommerce` es independiente.
- La implementación local se realizó sobre MariaDB 10.4.32 con InnoDB; la versión debe confirmarse en cualquier entorno nuevo (ver sección 8.1.1).
- El compañero digital 2D es la primera versión prevista; el 3D es una ampliación futura.
- El DER está elaborado con **12 entidades**.

### 2.2. Flujo conceptual

```text
Usuario
  │ HTTPS
  ▼
Frontend web
  │ HTML5 · CSS3 · JavaScript · Bootstrap 5 · SVG
  ▼
Backend PHP 8.x
  │ lógica de negocio · autenticación · PDO
  ▼
Capa de operaciones controladas
  │ validación · permisos · confirmación · trazabilidad
  ▼
MariaDB 10.4.32
  │ persistencia · integridad · auditoría
```

### 2.3. Implicaciones para la base de datos

- El backend será el único componente que acceda a MariaDB mediante PDO.
- KIRO no ejecutará consultas arbitrarias ni tendrá credenciales de base de datos.
- Las operaciones sensibles deberán coordinarse con la capa de aplicación y registrar su trazabilidad.
- La base de datos debe soportar un esquema multi-usuario con separación de información por propietario.
- La auditoría debe conservar las operaciones relevantes sin permitir su alteración desde la aplicación.

---

## 3. Inventario de las 12 entidades

### 3.1. Entidades oficiales

1. `USUARIO`
2. `REGISTRO_USUARIO`
3. `INICIO_SESION`
4. `PERFIL_KIRO`
5. `CITA`
6. `NOTA`
7. `PROYECTO`
8. `ACTIVIDAD`
9. `CATEGORIA`
10. `RECURSO`
11. `RECUERDO`
12. `HISTORIAL_ACCION`

### 3.2. Atributos del DER y adiciones aprobadas

| Entidad | Atributos del DER | Adiciones o cambios aprobados | PK y claves principales |
|---|---|---|---|
| **USUARIO** | `id_usuario` INT; `nombre` VARCHAR(100); `correo` VARCHAR(150); `fecha_registro` DATETIME | `hash_contrasena` VARCHAR(255) NOT NULL | PK `id_usuario`; UQ `correo` |
| **REGISTRO_USUARIO** | `id_registro` INT; `metodo_registro` VARCHAR(50); `estado_verificacion` VARCHAR(30); `fecha_verificacion` DATETIME; `id_usuario` INT | — | PK `id_registro`; FK `id_usuario`; UQ `id_usuario` |
| **INICIO_SESION** | `id_sesion` INT; `fecha_inicio` DATETIME; `fecha_fin` DATETIME; `estado_sesion` VARCHAR(30); `id_usuario` INT | — | PK `id_sesion`; FK `id_usuario` |
| **PERFIL_KIRO** | `id_perfil` INT; `nombre_companero` VARCHAR(50); `personalidad` VARCHAR(50); `estilo_comunicacion` VARCHAR(50); `color_principal` VARCHAR(30); `memoria_activa` BOOLEAN; `id_usuario` INT | — | PK `id_perfil`; FK `id_usuario`; UQ `id_usuario` |
| **CITA** | `id_cita` INT; `titulo` VARCHAR(150); `descripcion` TEXT; `fecha_inicio` DATETIME; `duracion_minutos` INT; `lugar` VARCHAR(200); `estado` VARCHAR(20); `id_usuario` INT | — | PK `id_cita`; FK `id_usuario` |
| **NOTA** | `id_nota` INT; `titulo` VARCHAR(150); `contenido` TEXT; `fecha_creacion` DATETIME; `fecha_actualizacion` DATETIME; `id_usuario` INT; `id_categoria` INT | — | PK `id_nota`; FK `id_usuario`; FK compuesta `(id_categoria, id_usuario)` |
| **PROYECTO** | `id_proyecto` INT; `nombre` VARCHAR(150); `descripcion` TEXT; `fecha_inicio` DATE; `fecha_fin` DATE; `estado` VARCHAR(20); `prioridad` VARCHAR(20); `id_usuario` INT | — | PK `id_proyecto`; FK `id_usuario`; UQ `(id_proyecto, id_usuario)` para FK compuesta |
| **ACTIVIDAD** | `id_actividad` INT; `titulo` VARCHAR(150); `descripcion` TEXT; `fecha_limite` DATE; `estado` VARCHAR(20); `prioridad` VARCHAR(20); `id_proyecto` INT | `id_usuario` INT NOT NULL | PK `id_actividad`; FK `id_usuario`; FK compuesta `(id_proyecto, id_usuario)`; `id_proyecto` nullable, `id_usuario` obligatorio |
| **CATEGORIA** | `id_categoria` INT; `nombre` VARCHAR(60); `descripcion` VARCHAR(200); `tipo` VARCHAR(20); `id_usuario` INT | — | PK `id_categoria`; FK `id_usuario`; UQ `(id_categoria, id_usuario)` para FK compuesta |
| **RECURSO** | `id_recurso` INT; `titulo` VARCHAR(150); `tipo` VARCHAR(30); `url` VARCHAR(500); `descripcion` TEXT; `fecha_registro` DATETIME; `id_usuario` INT; `id_categoria` INT | — | PK `id_recurso`; FK `id_usuario`; FK compuesta `(id_categoria, id_usuario)` |
| **RECUERDO** | `id_recuerdo` INT; `contenido` TEXT; `tipo` VARCHAR(40); `fecha_registro` DATETIME; `autorizado` BOOLEAN; `estado` VARCHAR(20); `id_usuario` INT | — | PK `id_recuerdo`; FK `id_usuario` |
| **HISTORIAL_ACCION** | `id_accion` INT; `tipo_accion` VARCHAR(50); `entidad_afectada` VARCHAR(50); `id_registro_afectado` INT; `descripcion` TEXT; `fecha_accion` DATETIME; `actor` VARCHAR(20); `resultado` VARCHAR(20); `id_usuario` INT | `id_registro_afectado` pasa a NULL cuando la acción no tiene un registro concreto | PK `id_accion`; FK `id_usuario`; sin FK hacia la entidad afectada |

> **Hecho:** las 12 entidades anteriores coinciden con la lista oficial y con el DER. Las únicas adiciones de atributos son las aprobadas: `USUARIO.hash_contrasena` y `ACTIVIDAD.id_usuario`. También están aprobadas las nulabilidades de `HISTORIAL_ACCION.id_registro_afectado`, `REGISTRO_USUARIO.fecha_verificacion` e `INICIO_SESION.fecha_fin` como NULL (sección 8.3). No se agregaron entidades.

---

## 4. Relaciones y cardinalidades

| Relación | Cardinalidad lógica | Implementación prevista | Observación |
|---|---|---|---|
| `USUARIO` → `REGISTRO_USUARIO` | 1 : 0..1 | FK `id_usuario` + UQ | La creación conjunta será transaccional para que todo usuario tenga registro. |
| `USUARIO` → `PERFIL_KIRO` | 1 : 0..1 | FK `id_usuario` + UQ | La creación conjunta será transaccional para que todo usuario tenga perfil. |
| `USUARIO` → `INICIO_SESION` | 1 : 0..N | FK `id_usuario` | Un usuario puede tener muchas sesiones. |
| `USUARIO` → `CITA` | 1 : 0..N | FK `id_usuario` | Agenda personal por usuario. |
| `USUARIO` → `NOTA` | 1 : 0..N | FK `id_usuario` | Notas propias del usuario. |
| `USUARIO` → `PROYECTO` | 1 : 0..N | FK `id_usuario` | Proyectos propios del usuario. |
| `USUARIO` → `ACTIVIDAD` | 1 : 0..N | FK `id_usuario` | Nueva relación aprobada para dar propietario a toda actividad. |
| `USUARIO` → `CATEGORIA` | 1 : 0..N | FK `id_usuario` | Categorías propias del usuario. |
| `USUARIO` → `RECURSO` | 1 : 0..N | FK `id_usuario` | Recursos propios del usuario. |
| `USUARIO` → `RECUERDO` | 1 : 0..N | FK `id_usuario` | Recuerdos propios del usuario. |
| `USUARIO` → `HISTORIAL_ACCION` | 1 : 0..N | FK `id_usuario` | Historial de acciones de la cuenta. |
| `CATEGORIA` → `NOTA` | 1 : 0..N | FK compuesta `(id_categoria, id_usuario)` | La nota puede no tener categoría. |
| `CATEGORIA` → `RECURSO` | 1 : 0..N | FK compuesta `(id_categoria, id_usuario)` | El recurso puede no tener categoría. |
| `PROYECTO` → `ACTIVIDAD` | 1 : 0..N | FK compuesta `(id_proyecto, id_usuario)` | La actividad puede ser independiente si `id_proyecto` es NULL. |
| `HISTORIAL_ACCION` → entidad afectada | Lógica, sin FK | `entidad_afectada` + `id_registro_afectado` | Referencia polimórfica validada por la aplicación o por mecanismos controlados. |

### 4.1. Lectura de las cardinalidades

- Las relaciones 1:0..1 se derivan de la unicidad de `id_usuario` en `REGISTRO_USUARIO` y `PERFIL_KIRO`.
- La participación total de `USUARIO` hacia `REGISTRO_USUARIO` y `PERFIL_KIRO` no puede imponerse solo con una FK; se garantizará funcionalmente con una transacción de creación.
- Las relaciones 1:0..N se derivan de FKs no únicas.
- La relación `PROYECTO`–`ACTIVIDAD` es opcional del lado de la actividad: `id_proyecto` admite NULL. La FK compuesta se evalúa solo cuando `id_proyecto` no es NULL; `id_usuario` sigue siendo obligatorio y se valida con su propia FK hacia `USUARIO`.
- La relación de auditoría con la entidad afectada es lógica, no referencial, porque una sola columna no puede apuntar a varias tablas.

---

## 5. Normalización y redundancias

### 5.1. Evaluación

**Conclusión prudente:** el modelo presenta una estructura compatible con los principios de normalización. No se identifican redundancias estructurales evidentes en el DER y los atributos son atómicos, sin grupos repetidos. Sin embargo, este documento **no declara el cumplimiento formal de 1NF, 2NF ni 3NF**: la confirmación formal de 2NF y 3NF requiere documentar las dependencias funcionales y contrastarlas con las reglas de negocio, tarea que no forma parte de este plan.

| Aspecto | Observación preliminar |
|---|---|
| Atomicidad de atributos | Los atributos del DER son atómicos y no se observan grupos repetidos; esto es compatible con 1NF, sin que constituya una demostración formal. |
| Dependencias parciales | No se identifican dependencias parciales evidentes; su confirmación formal requiere analizar las dependencias funcionales de cada relación. |
| Dependencias transitivas | No se identifican redundancias estructurales evidentes; las redundancias conocidas están justificadas en la sección 5.3 y deben validarse con las reglas de negocio. |
| Conclusión | Estructura compatible con los principios de normalización; cumplimiento formal **no demostrado** en este documento. |

### 5.2. Separaciones justificadas

- **`REGISTRO_USUARIO` separado de `USUARIO`:** representa el proceso de registro y verificación, no los datos principales de la cuenta. `USUARIO.fecha_registro` sigue siendo la fecha oficial de creación y no se duplica.
- **`PERFIL_KIRO` separado de `USUARIO`:** contiene configuración, personalidad y preferencias del compañero; tiene un ciclo de vida distinto al de la cuenta.
- **`INICIO_SESION` separado de `USUARIO`:** registra eventos de acceso y permite historial por sesión.
- **`HISTORIAL_ACCION` separado:** es una tabla de auditoría con propósito y permisos propios.

### 5.3. Redundancias controladas

| Redundancia | Justificación | Protección prevista |
|---|---|---|
| `NOTA.id_usuario` y `RECURSO.id_usuario` junto a `id_categoria` | La categoría es opcional y el propietario del registro debe existir incluso sin categoría. | FK compuesta `(id_categoria, id_usuario)` para impedir categorías de otro usuario. |
| `ACTIVIDAD.id_usuario` junto a `PROYECTO.id_usuario` | Una actividad puede ser independiente y, por tanto, necesita propietario directo. | FK compuesta `(id_proyecto, id_usuario)` para asegurar que el proyecto sea del mismo usuario. |
| `HISTORIAL_ACCION.actor` e `id_usuario` | `actor` identifica el origen de la acción; `id_usuario` identifica la cuenta afectada. | Dominios de `actor` pendientes de definición. |
| `RECUERDO.autorizado` y `RECUERDO.estado` | Pueden representar consentimiento y ciclo de vida, respectivamente. | Semántica pendiente de confirmación. |
| `PERFIL_KIRO.memoria_activa` y `RECUERDO.autorizado` | El primero es un interruptor global; el segundo, una autorización por recuerdo. | Precedencia pendiente de definición. |

### 5.4. Campos derivados

- `CITA` almacena `fecha_inicio` y `duracion_minutos`; la hora de fin se calcula y no se almacena. Esto evita una dependencia derivada innecesaria.
- `NOTA.fecha_actualizacion` es un dato de control temporal; deberá mantenerse en la aplicación o mediante un mecanismo controlado.
- No se almacenan totales ni resúmenes precalculados en el modelo actual.

---

## 6. Problemas detectados y soluciones aprobadas

### 6.1. Credenciales de autenticación

**Hecho:** `USUARIO` no contenía un atributo para contraseña o hash.

**Problema:** el README exige autenticación con contraseñas protegidas mediante Argon2id o bcrypt, pero el DER no permitía almacenar la credencial.

**Decisión aprobada:** añadir `hash_contrasena VARCHAR(255) NOT NULL` a `USUARIO`.

**Criterios:**

- Nunca se almacena la contraseña en texto plano.
- El hash se genera en el backend con un algoritmo aprobado.
- `VARCHAR(255)` cubre los formatos de hash previstos y permite evolución.
- La verificación de la contraseña se realiza en la aplicación, no en MariaDB.

### 6.2. Propietario de las actividades

**Hecho:** `ACTIVIDAD` solo tenía `id_proyecto`, que es nullable.

**Problema:** una actividad independiente no tenía forma de asociarse a un usuario.

**Decisión aprobada:** añadir `id_usuario INT NOT NULL` a `ACTIVIDAD`, manteniendo `id_proyecto` como FK opcional.

**Criterios:**

- Toda actividad tiene propietario, sea independiente o esté asociada a un proyecto.
- Si `id_proyecto` no es NULL, el proyecto debe pertenecer al mismo usuario.
- La integridad se refuerza con la FK compuesta `(id_proyecto, id_usuario)`.
- Si `id_proyecto` es NULL, la actividad sigue teniendo `id_usuario` y sigue siendo válida.

**Comportamiento de la FK compuesta `(id_proyecto, id_usuario)`:**

- En MariaDB, una FK compuesta se valida cuando todas sus columnas son distintas de NULL. Si `id_proyecto` es NULL, la referencia a `PROYECTO` no se evalúa y la actividad se considera independiente.
- Ese NULL **no** exime de propietario: `id_usuario` es `NOT NULL` y su FK independiente hacia `USUARIO` se sigue validando.
- Si `id_proyecto` no es NULL, ambos valores deben coincidir con un proyecto del mismo usuario.
- El NULL solo afecta a la referencia al proyecto; el propietario nunca es opcional.

### 6.3. Categorías de otros usuarios

**Hecho:** `NOTA` y `RECURSO` tienen `id_usuario` e `id_categoria`; `CATEGORIA` tiene su propio `id_usuario`. La FK original solo referenciaba `id_categoria`.

**Problema:** una nota o recurso podía apuntar a una categoría de otro usuario.

**Decisión aprobada:** usar FKs compuestas `(id_categoria, id_usuario)` en `NOTA` y `RECURSO`.

**Criterios:**

- `CATEGORIA` debe tener un índice único `(id_categoria, id_usuario)` para servir como destino de la FK compuesta.
- `NOTA` y `RECURSO` deben tener el índice correspondiente para la FK compuesta.
- Si `id_categoria` es NULL, la relación no se aplica; la nota o el recurso siguen siendo válidos.
- No se añaden atributos nuevos: se reutilizan `id_categoria` e `id_usuario`.

### 6.4. Auditoría polimórfica

**Hecho:** `HISTORIAL_ACCION` usa `entidad_afectada` e `id_registro_afectado` para referirse a distintas tablas.

**Problema:** no es posible una FK convencional hacia múltiples entidades. Además, algunas acciones pueden no tener un registro concreto.

**Decisión aprobada:** conservar la referencia polimórfica y permitir que `id_registro_afectado` sea NULL.

**Criterios:**

- La aplicación o un mecanismo controlado de base de datos valida que `entidad_afectada` corresponda a una entidad permitida.
- Cuando `id_registro_afectado` no sea NULL, se valida la existencia del registro afectado antes de registrar la acción.
- Esa validación debe coordinarse con la operación auditada y su transacción, considerando posibles modificaciones o eliminaciones concurrentes del registro referenciado.
- Una validación aislada puede quedar desactualizada antes de insertar la auditoría: el registro podría modificarse o eliminarse entre la comprobación y la escritura. El mecanismo debe evitar o detectar ese intervalo.
- El mecanismo concreto de validación sigue pendiente; no se implementan triggers ni se fija una solución definitiva en esta etapa (sección 7.4).
- El usuario de aplicación tendrá permiso de inserción, pero no de actualización ni eliminación sobre `HISTORIAL_ACCION`.
- `actor`, `resultado` y `tipo_accion` quedan sujetos a los dominios pendientes.
- Las operaciones relevantes y su registro de auditoría deben ser atómicos: se ejecutan en la misma transacción y la operación no se confirma si la auditoría no se registra.
- Si se requiere auditar un intento fallido, el registro debe escribirse en una transacción independiente, porque el rollback de la operación eliminaría la fila de auditoría.

### 6.5. Registro y perfil obligatorios

**Hecho:** las FKs únicas permiten como máximo un `REGISTRO_USUARIO` y un `PERFIL_KIRO` por usuario, pero no obligan a que existan.

**Decisión aprobada:** todo usuario debe contar funcionalmente con un `REGISTRO_USUARIO` y un `PERFIL_KIRO`; su creación se realizará junto con `USUARIO` mediante una transacción.

**Criterios:**

- La transacción crea `USUARIO`, `REGISTRO_USUARIO` y `PERFIL_KIRO`.
- Si falla cualquier inserción, se revierte toda la operación.
- La base de datos garantiza el máximo de uno por usuario mediante UQ. La existencia de ambos registros por cada usuario es un **requisito funcional obligatorio**, pero el mecanismo técnico para garantizarlo sigue **pendiente** y se documenta en la sección 7.6. No se presenta la capa de aplicación como una decisión ya aprobada.
- La obligatoriedad funcional exige **centralizar la creación de usuarios** en un único flujo del backend: ningún otro módulo debe insertar en `USUARIO`, `REGISTRO_USUARIO` o `PERFIL_KIRO` por separado.
- Exige además **controlar los permisos de inserción**: el usuario de aplicación general no debe poder insertar directamente en estas tres tablas fuera del flujo de alta. Las opciones técnicas (credencial dedicada, rol restringido o rutina controlada) siguen pendientes de definición (sección 7.6).
- Una FK no puede imponer participación total; si se requiere una garantía adicional dentro de la base de datos, deberá evaluarse un mecanismo controlado, sin crearlo en esta etapa. El mecanismo concreto sigue pendiente (sección 7.6).
- No se crean entidades nuevas.

### 6.6. Recomendaciones técnicas no cerradas

Las siguientes medidas son recomendaciones para la implementación. No sustituyen decisiones de negocio ni deben aplicarse como restricciones definitivas hasta su validación:

- **RN-07 (solapamiento de citas):** el final de una cita se calcula a partir de `fecha_inicio` y `duracion_minutos`. La comprobación de intervalos debe contemplar la concurrencia y requerirá una estrategia de serialización y bloqueo adecuada, diseñada según los índices disponibles. La estrategia concreta queda pendiente de especificación y prueba durante la implementación; este plan no la considera garantizada.
- Validar que `duracion_minutos` sea mayor que cero.
- Coherencia entre `PROYECTO.fecha_inicio` y `PROYECTO.fecha_fin`: condición pendiente de confirmación, incluida la validez o no de fechas iguales.
- Coherencia entre `NOTA.fecha_creacion` y `NOTA.fecha_actualizacion`: condición pendiente de confirmación, incluida la validez o no de fechas iguales.
- Coherencia entre `INICIO_SESION.fecha_inicio` y `INICIO_SESION.fecha_fin`: condición pendiente de confirmación, incluida la validez o no de fechas iguales. La nulabilidad de `fecha_fin` ya está aprobada como NULL y la condición debe contemplar ese caso.
- Evaluar la unicidad de `CATEGORIA.nombre` por usuario.
- Evaluar un índice de texto completo para búsquedas en notas y recuerdos, según los casos de uso.
- MariaDB 10.4.32 admite restricciones `CHECK` y las aplica, pero no se incorporan hasta que se aprueben los dominios y las reglas de coherencia correspondientes (ver secciones 8.1.1 y 9.4).

---

## 7. Decisiones pendientes

> Las siguientes decisiones no se cierran en este documento. No se crearán restricciones ni atributos asociados hasta revisar los requisitos correspondientes.

### 7.1. Política de eliminación

**Pendiente:** definir qué entidades tendrán eliminación lógica, qué atributo las marcaría, cómo se recuperarían y qué ocurre con los registros dependientes.

Consideraciones:

- El README menciona en RN-09 la eliminación lógica y la recuperación, pero el DER no contiene un atributo específico para ello.
- No se debe añadir un atributo de borrado lógico sin justificación y aprobación.
- Las acciones referenciales ya están aprobadas como `ON DELETE RESTRICT` y `ON UPDATE RESTRICT`; esta política pendiente no las modifica (sección 9.2).
- Mientras no se defina la eliminación lógica, no se generalizarán borrados en cascada.
- La auditoría debe conservarse con independencia de la política que se elija.

### 7.2. Dominios de valores

**Pendiente:** definir los valores permitidos para:

- Estados: `CITA.estado`, `PROYECTO.estado`, `ACTIVIDAD.estado`, `RECUERDO.estado`.
- Prioridades: `PROYECTO.prioridad`, `ACTIVIDAD.prioridad`.
- Tipos: `CATEGORIA.tipo`, `RECURSO.tipo`, `RECUERDO.tipo`.
- Verificación: `REGISTRO_USUARIO.metodo_registro`, `REGISTRO_USUARIO.estado_verificacion`.
- Sesiones: `INICIO_SESION.estado_sesion`.
- Auditoría: `HISTORIAL_ACCION.actor`, `HISTORIAL_ACCION.resultado`, `HISTORIAL_ACCION.tipo_accion`.

No se definirán valores ni restricciones CHECK de dominio hasta contar con los requisitos. Las columnas se mantienen como `VARCHAR` en el plan. MariaDB 10.4.32 admite `CHECK`, pero su incorporación queda pendiente de la aprobación de los dominios.

### 7.3. Semántica de memoria y autorización

**Pendiente:** confirmar la relación entre `PERFIL_KIRO.memoria_activa`, `RECUERDO.autorizado` y `RECUERDO.estado`, así como el valor por defecto de `memoria_activa`.

No se asume un comportamiento ni un valor predeterminado.

### 7.4. Mecanismo de validación de auditoría

**Pendiente técnico:** definir si la validación de la referencia polimórfica se realizará en la aplicación, mediante triggers o mediante una combinación de ambos. La decisión aprobada exige validación controlada y permisos de solo inserción, pero no fija el mecanismo.

La definición debe incluir cómo se coordina la comprobación de existencia de `id_registro_afectado` con la operación auditada y su transacción, para evitar que una validación aislada quede desactualizada ante modificaciones o eliminaciones concurrentes antes de insertar la auditoría. Este plan no elige todavía entre aplicación, triggers o combinación, ni propone una implementación concreta.

### 7.5. Estrategia de concurrencia para citas (RN-07)

**Pendiente de especificación técnica:** definir la estrategia de serialización y bloqueo que impida solapamientos concurrentes de citas. El fin de la cita se calcula a partir de `fecha_inicio` y `duracion_minutos`; la comprobación debe considerar la concurrencia y los índices disponibles. Una consulta de intervalos por sí sola no garantiza la ausencia de solapamientos, por lo que la estrategia concreta se especificará y probará durante la implementación.

### 7.6. Mecanismo de registros obligatorios

**Pendiente técnico:** definir cómo se garantiza funcionalmente que todo `USUARIO` tenga un `REGISTRO_USUARIO` y un `PERFIL_KIRO`.

La transacción de alta y la centralización de la creación de usuarios están aprobadas (sección 6.5), pero el mecanismo de control no está fijado. Las opciones —aplicación, permisos restringidos, rutina controlada u otra— siguen pendientes. La base de datos solo garantiza el máximo de uno por usuario mediante UQ; no garantiza la existencia.

Este plan no crea ningún mecanismo adicional ni modifica las FKs o UQ para imponer la participación total.

---

## 8. Tipos de datos propuestos para MariaDB 10.4.32

### 8.1. Criterios generales

- Se respetan los tipos y longitudes del DER.
- Los identificadores se mantienen como `INT`, según el DER y las decisiones aprobadas.
- **Aprobado:** `AUTO_INCREMENT` en las claves primarias numéricas de las 12 entidades. No se utiliza en columnas que no sean PK.
- Los textos se almacenarán en `utf8mb4`.
- **Collation definida:** `utf8mb4_unicode_ci` (ver sección 8.1.2).
- Los booleanos se representan como `TINYINT(1)` o `BOOLEAN`.
- Las fechas y horas usan `DATETIME`; las fechas sin hora usan `DATE`.
- Los textos largos usan `TEXT`.
- Los dominios no se implementan con `ENUM` ni `CHECK` hasta que se aprueben sus valores.
- No se declaran valores `DEFAULT` nuevos para atributos sin valor aprobado (ver sección 8.4).

### 8.1.1. Entorno y compatibilidad

- El SGBD confirmado es **MariaDB 10.4.32** con motor **InnoDB**. MySQL Workbench se utiliza como cliente de administración, no como servidor.
- La **versión real del servidor** debe verificarse en cada entorno nuevo, por ejemplo con `SELECT VERSION()`, y confirmarse que corresponde a MariaDB 10.4.32.
- MariaDB 10.4.32 **admite restricciones `CHECK` y las aplica**. Sin embargo, en este plan no se incorporan `CHECK` de dominios ni de coherencia de fechas porque las reglas funcionales siguen pendientes (secciones 7.2, 9.4 y 14).
- Las características utilizadas en el plan (`InnoDB`, `utf8mb4`, `utf8mb4_unicode_ci`, `AUTO_INCREMENT`, claves foráneas simples y compuestas, `UNIQUE` e índices) están disponibles en MariaDB 10.4.32. No se asume compatibilidad con características exclusivas de otras versiones o SGBD.
- **Nombre de la base implementada:** la base creada en el entorno local se denomina `Kiro`. El borrador anterior usaba `kiro` en minúsculas; esa variante no debe reutilizarse. El nombre para entornos futuros debe confirmarse en el checklist (sección 14).

### 8.1.2. Charset y collation

- Charset: **`utf8mb4`**.
- Collation: **`utf8mb4_unicode_ci`**.
- `utf8mb4_unicode_ci` está disponible en MariaDB 10.4.32 y es compatible con InnoDB.
- Esta collation realiza comparaciones **sin distinguir mayúsculas ni acentos**. Por tanto, la restricción `UNIQUE` de `USUARIO.correo` también se evalúa con ese criterio: dos correos que solo difieran en mayúsculas o en acentos se considerarán duplicados.
- No se cambia la collation por otra sin una justificación técnica y su aprobación correspondiente.
- Las longitudes de las columnas indexadas del DER están dentro de los límites de índice de InnoDB para `utf8mb4`; no se requieren prefijos de índice.

### 8.2. Correspondencia de tipos

| Uso | Tipo MariaDB 10.4.32 propuesto | Observación |
|---|---|---|
| Claves primarias y foráneas | `INT` | Coherente con el DER. `AUTO_INCREMENT` aprobado en PK. |
| Nombres, títulos y descripciones cortas | `VARCHAR(n)` | Longitud según el DER; `utf8mb4`. |
| Contenido y descripciones largas | `TEXT` | `NOTA.contenido`, `RECURSO.descripcion`, etc. |
| Booleanos | `BOOLEAN` / `TINYINT(1)` | `PERFIL_KIRO.memoria_activa`, `RECUERDO.autorizado`. |
| Fechas | `DATE` | `PROYECTO.fecha_inicio`, `PROYECTO.fecha_fin`, `ACTIVIDAD.fecha_limite`. |
| Fechas y horas | `DATETIME` | Registros, sesiones, citas y auditoría. |
| Hash de contraseña | `VARCHAR(255)` | Añadido aprobado a `USUARIO`. |
| Referencia de auditoría | `INT NULL` | `HISTORIAL_ACCION.id_registro_afectado`; aprobado como nullable. |

### 8.3. Matriz de nulabilidad

**Criterios de lectura:**

- **Aprobada:** existe una decisión aprobada que fija la nulabilidad.
- **Derivada del DER:** el DER no marca el atributo como `NULL`; se interpreta como obligatorio según la notación del diagrama.
- **Pendiente:** no hay información suficiente para decidir; **no implica que el atributo deba ser opcional**. En la revisión actual no queda ninguna nulabilidad en esta categoría.

El DER marca explícitamente `NULL` solo en `NOTA.id_categoria`, `RECURSO.id_categoria` y `ACTIVIDAD.id_proyecto`. Las claves primarias son NOT NULL por definición. Las demás ausencias de marca se interpretan como NOT NULL; si el equipo usa otra convención de notación, esta matriz debe revisarse.

| Entidad | Atributo | Nulabilidad | Clasificación | Base |
|---|---|---|---|---|
| `USUARIO` | `id_usuario` | NOT NULL | Derivada del DER | PK |
| `USUARIO` | `nombre` | NOT NULL | Derivada del DER | DER |
| `USUARIO` | `correo` | NOT NULL | Derivada del DER | DER; UQ |
| `USUARIO` | `fecha_registro` | NOT NULL | Derivada del DER | DER |
| `USUARIO` | `hash_contrasena` | NOT NULL | **Aprobada** | Decisión aprobada |
| `REGISTRO_USUARIO` | `id_registro` | NOT NULL | Derivada del DER | PK |
| `REGISTRO_USUARIO` | `metodo_registro` | NOT NULL | Derivada del DER | DER |
| `REGISTRO_USUARIO` | `estado_verificacion` | NOT NULL | Derivada del DER | DER |
| `REGISTRO_USUARIO` | `fecha_verificacion` | NULL | **Aprobada** | Decisión aprobada |
| `REGISTRO_USUARIO` | `id_usuario` | NOT NULL | Derivada del DER | DER; FK y UQ |
| `INICIO_SESION` | `id_sesion` | NOT NULL | Derivada del DER | PK |
| `INICIO_SESION` | `fecha_inicio` | NOT NULL | Derivada del DER | DER |
| `INICIO_SESION` | `fecha_fin` | NULL | **Aprobada** | Decisión aprobada |
| `INICIO_SESION` | `estado_sesion` | NOT NULL | Derivada del DER | DER |
| `INICIO_SESION` | `id_usuario` | NOT NULL | Derivada del DER | DER; FK |
| `PERFIL_KIRO` | `id_perfil` | NOT NULL | Derivada del DER | PK |
| `PERFIL_KIRO` | `nombre_companero` | NOT NULL | Derivada del DER | DER |
| `PERFIL_KIRO` | `personalidad` | NOT NULL | Derivada del DER | DER |
| `PERFIL_KIRO` | `estilo_comunicacion` | NOT NULL | Derivada del DER | DER |
| `PERFIL_KIRO` | `color_principal` | NOT NULL | Derivada del DER | DER |
| `PERFIL_KIRO` | `memoria_activa` | NOT NULL | Derivada del DER | DER |
| `PERFIL_KIRO` | `id_usuario` | NOT NULL | Derivada del DER | DER; FK y UQ |
| `CITA` | `id_cita` | NOT NULL | Derivada del DER | PK |
| `CITA` | `titulo` | NOT NULL | Derivada del DER | DER |
| `CITA` | `descripcion` | NOT NULL | Derivada del DER | DER |
| `CITA` | `fecha_inicio` | NOT NULL | Derivada del DER | DER |
| `CITA` | `duracion_minutos` | NOT NULL | Derivada del DER | DER |
| `CITA` | `lugar` | NOT NULL | Derivada del DER | DER |
| `CITA` | `estado` | NOT NULL | Derivada del DER | DER |
| `CITA` | `id_usuario` | NOT NULL | Derivada del DER | DER; FK |
| `NOTA` | `id_nota` | NOT NULL | Derivada del DER | PK |
| `NOTA` | `titulo` | NOT NULL | Derivada del DER | DER |
| `NOTA` | `contenido` | NOT NULL | Derivada del DER | DER |
| `NOTA` | `fecha_creacion` | NOT NULL | Derivada del DER | DER |
| `NOTA` | `fecha_actualizacion` | NOT NULL | Derivada del DER | DER |
| `NOTA` | `id_usuario` | NOT NULL | Derivada del DER | DER; FK |
| `NOTA` | `id_categoria` | NULL | **Aprobada** | DER lo marca NULL; decisión aprobada |
| `PROYECTO` | `id_proyecto` | NOT NULL | Derivada del DER | PK |
| `PROYECTO` | `nombre` | NOT NULL | Derivada del DER | DER |
| `PROYECTO` | `descripcion` | NOT NULL | Derivada del DER | DER |
| `PROYECTO` | `fecha_inicio` | NOT NULL | Derivada del DER | DER |
| `PROYECTO` | `fecha_fin` | NOT NULL | Derivada del DER | DER |
| `PROYECTO` | `estado` | NOT NULL | Derivada del DER | DER |
| `PROYECTO` | `prioridad` | NOT NULL | Derivada del DER | DER |
| `PROYECTO` | `id_usuario` | NOT NULL | Derivada del DER | DER; FK |
| `ACTIVIDAD` | `id_actividad` | NOT NULL | Derivada del DER | PK |
| `ACTIVIDAD` | `titulo` | NOT NULL | Derivada del DER | DER |
| `ACTIVIDAD` | `descripcion` | NOT NULL | Derivada del DER | DER |
| `ACTIVIDAD` | `fecha_limite` | NOT NULL | Derivada del DER | DER |
| `ACTIVIDAD` | `estado` | NOT NULL | Derivada del DER | DER |
| `ACTIVIDAD` | `prioridad` | NOT NULL | Derivada del DER | DER |
| `ACTIVIDAD` | `id_proyecto` | NULL | **Aprobada** | DER lo marca NULL |
| `ACTIVIDAD` | `id_usuario` | NOT NULL | **Aprobada** | Decisión aprobada |
| `CATEGORIA` | `id_categoria` | NOT NULL | Derivada del DER | PK |
| `CATEGORIA` | `nombre` | NOT NULL | Derivada del DER | DER |
| `CATEGORIA` | `descripcion` | NOT NULL | Derivada del DER | DER |
| `CATEGORIA` | `tipo` | NOT NULL | Derivada del DER | DER |
| `CATEGORIA` | `id_usuario` | NOT NULL | Derivada del DER | DER; FK |
| `RECURSO` | `id_recurso` | NOT NULL | Derivada del DER | PK |
| `RECURSO` | `titulo` | NOT NULL | Derivada del DER | DER |
| `RECURSO` | `tipo` | NOT NULL | Derivada del DER | DER |
| `RECURSO` | `url` | NOT NULL | Derivada del DER | DER |
| `RECURSO` | `descripcion` | NOT NULL | Derivada del DER | DER |
| `RECURSO` | `fecha_registro` | NOT NULL | Derivada del DER | DER |
| `RECURSO` | `id_usuario` | NOT NULL | Derivada del DER | DER; FK |
| `RECURSO` | `id_categoria` | NULL | **Aprobada** | DER lo marca NULL; decisión aprobada |
| `RECUERDO` | `id_recuerdo` | NOT NULL | Derivada del DER | PK |
| `RECUERDO` | `contenido` | NOT NULL | Derivada del DER | DER |
| `RECUERDO` | `tipo` | NOT NULL | Derivada del DER | DER |
| `RECUERDO` | `fecha_registro` | NOT NULL | Derivada del DER | DER |
| `RECUERDO` | `autorizado` | NOT NULL | Derivada del DER | DER |
| `RECUERDO` | `estado` | NOT NULL | Derivada del DER | DER |
| `RECUERDO` | `id_usuario` | NOT NULL | Derivada del DER | DER; FK |
| `HISTORIAL_ACCION` | `id_accion` | NOT NULL | Derivada del DER | PK |
| `HISTORIAL_ACCION` | `tipo_accion` | NOT NULL | Derivada del DER | DER |
| `HISTORIAL_ACCION` | `entidad_afectada` | NOT NULL | Derivada del DER | DER |
| `HISTORIAL_ACCION` | `id_registro_afectado` | NULL | **Aprobada** | Decisión aprobada |
| `HISTORIAL_ACCION` | `descripcion` | NOT NULL | Derivada del DER | DER |
| `HISTORIAL_ACCION` | `fecha_accion` | NOT NULL | Derivada del DER | DER |
| `HISTORIAL_ACCION` | `actor` | NOT NULL | Derivada del DER | DER |
| `HISTORIAL_ACCION` | `resultado` | NOT NULL | Derivada del DER | DER |
| `HISTORIAL_ACCION` | `id_usuario` | NOT NULL | Derivada del DER | DER; FK |

**Resumen:** 82 atributos. 2 nulabilidades NOT NULL aprobadas (`USUARIO.hash_contrasena`, `ACTIVIDAD.id_usuario`), 6 nulabilidades NULL aprobadas (`ACTIVIDAD.id_proyecto`, `NOTA.id_categoria`, `RECURSO.id_categoria`, `HISTORIAL_ACCION.id_registro_afectado`, `REGISTRO_USUARIO.fecha_verificacion`, `INICIO_SESION.fecha_fin`) y 74 derivadas de la notación del DER o de la definición de PK. No quedan nulabilidades pendientes.

> **Decisiones aplicadas.** `REGISTRO_USUARIO.fecha_verificacion` e `INICIO_SESION.fecha_fin` se definen como NULL: una cuenta puede estar registrada sin verificación completada y una sesión activa todavía no tiene fecha de finalización.

### 8.4. Valores por defecto

No se establecen valores `DEFAULT` nuevos para `PERFIL_KIRO.memoria_activa`, `RECUERDO.autorizado` ni para otros atributos sin valor predeterminado aprobado. Los valores por defecto de esos atributos siguen pendientes de definición funcional (sección 7.3).

> Esta sección no crea restricciones: solo documenta que el plan no fija `DEFAULT` para esos atributos.

### 8.5. Estado de las decisiones y de los scripts SQL

> El script canónico es `database/KIRO_MariaDB.sql`, ejecutado en MariaDB 10.4.32. El archivo `database/kiro_schema_draft.sql` es un borrador anterior, no vigente y no autorizado para ejecutarse. Esta tabla distingue lo incorporado al diseño, lo implementado, lo pendiente y lo definido solo para el entorno local.

| Aspecto | Estado | Alcance |
|---|---|---|
| `REGISTRO_USUARIO.fecha_verificacion` NULL | **Decisión incorporada** | Secciones 8.3 y 9.4 |
| `INICIO_SESION.fecha_fin` NULL | **Decisión incorporada** | Secciones 8.3 y 9.4 |
| FKs con `ON DELETE RESTRICT` y `ON UPDATE RESTRICT` | **Decisión incorporada** | Sección 9.2 |
| Charset `utf8mb4` y collation `utf8mb4_unicode_ci` | **Decisión incorporada** | Sección 8.1.2 |
| `AUTO_INCREMENT` en las PK numéricas | **Decisión incorporada** | Sección 8.1 |
| Script canónico `database/KIRO_MariaDB.sql` | **Vigente** | Implementación ejecutada en MariaDB 10.4.32 |
| Borrador `database/kiro_schema_draft.sql` | **No vigente** | Reemplazado por el script canónico |
| Nombre `Kiro` de la base de datos | **Definido en la implementación local** | Base creada; pendiente confirmar el nombre para entornos futuros (secciones 8.1.1 y 14) |
| 12 tablas, 12 PK, 14 FK y 120 registros de prueba | **Implementado** | Script canónico; 10 registros por tabla |
| 19 índices secundarios (5 `UNIQUE` y 14 `KEY`) | **Implementado** | Sección 10 |
| Análisis de índices con `EXPLAIN` | **Pendiente** | Sección 12.6; la práctica en `db_ecommerce` es independiente |
| Dominios y `CHECK` de estados, prioridades, tipos, actor, resultado y tipo de acción | **Pendiente** | Sección 7.2 |
| Valores `DEFAULT` | **Pendiente** | Sección 8.4 |
| Eliminación lógica | **Pendiente** | Sección 7.1 |
| Validación de la referencia polimórfica | **Pendiente** | Sección 7.4 |
| Coherencia de fechas y validez de fechas iguales | **Pendiente** | Secciones 6.6 y 9.4 |
| Duración positiva de `CITA` | **Pendiente** | Sección 6.6 |
| Unicidad `(id_usuario, nombre)` en `CATEGORIA` | **Pendiente** | Sección 9.3 |
| Estrategia de concurrencia para citas (RN-07) | **Pendiente** | Sección 7.5 |
| Mecanismo de registros obligatorios `REGISTRO_USUARIO` y `PERFIL_KIRO` | **Pendiente** | Sección 7.6 |
| Índices candidatos de la sección 10.3 | **Pendiente** | Sección 10.3 |

> Ninguna decisión pendiente queda aprobada por aparecer en el script o por estar documentada como `TODO`. La revisión técnica del plan sigue abierta.

---

## 9. Claves primarias, foráneas, únicas y restricciones

### 9.1. Claves primarias

| Entidad | Clave primaria |
|---|---|
| `USUARIO` | `id_usuario` |
| `REGISTRO_USUARIO` | `id_registro` |
| `INICIO_SESION` | `id_sesion` |
| `PERFIL_KIRO` | `id_perfil` |
| `CITA` | `id_cita` |
| `NOTA` | `id_nota` |
| `PROYECTO` | `id_proyecto` |
| `ACTIVIDAD` | `id_actividad` |
| `CATEGORIA` | `id_categoria` |
| `RECURSO` | `id_recurso` |
| `RECUERDO` | `id_recuerdo` |
| `HISTORIAL_ACCION` | `id_accion` |

### 9.2. Claves foráneas

| Tabla hija | Columna(s) | Tabla padre | Columna(s) | Observación |
|---|---|---|---|---|
| `REGISTRO_USUARIO` | `id_usuario` | `USUARIO` | `id_usuario` | UQ en hija. |
| `INICIO_SESION` | `id_usuario` | `USUARIO` | `id_usuario` | — |
| `PERFIL_KIRO` | `id_usuario` | `USUARIO` | `id_usuario` | UQ en hija. |
| `CITA` | `id_usuario` | `USUARIO` | `id_usuario` | — |
| `NOTA` | `id_usuario` | `USUARIO` | `id_usuario` | — |
| `NOTA` | `(id_categoria, id_usuario)` | `CATEGORIA` | `(id_categoria, id_usuario)` | Compuesta y opcional si `id_categoria` es NULL. |
| `PROYECTO` | `id_usuario` | `USUARIO` | `id_usuario` | — |
| `ACTIVIDAD` | `id_usuario` | `USUARIO` | `id_usuario` | Propietario directo. |
| `ACTIVIDAD` | `(id_proyecto, id_usuario)` | `PROYECTO` | `(id_proyecto, id_usuario)` | Compuesta; opcional si `id_proyecto` es NULL. |
| `CATEGORIA` | `id_usuario` | `USUARIO` | `id_usuario` | — |
| `RECURSO` | `id_usuario` | `USUARIO` | `id_usuario` | — |
| `RECURSO` | `(id_categoria, id_usuario)` | `CATEGORIA` | `(id_categoria, id_usuario)` | Compuesta y opcional si `id_categoria` es NULL. |
| `RECUERDO` | `id_usuario` | `USUARIO` | `id_usuario` | — |
| `HISTORIAL_ACCION` | `id_usuario` | `USUARIO` | `id_usuario` | — |

> **Conteo verificado:** el modelo tiene **14 claves foráneas**: **11 simples** y **3 compuestas**. Las compuestas son `NOTA(id_categoria, id_usuario)`, `RECURSO(id_categoria, id_usuario)` y `ACTIVIDAD(id_proyecto, id_usuario)`. Las 11 simples apuntan todas a `USUARIO(id_usuario)`: `REGISTRO_USUARIO`, `INICIO_SESION`, `PERFIL_KIRO`, `CITA`, `NOTA`, `PROYECTO`, `ACTIVIDAD`, `CATEGORIA`, `RECURSO`, `RECUERDO` y `HISTORIAL_ACCION`.

> **Acciones referenciales aprobadas.** Todas las FKs de la tabla anterior usan `ON DELETE RESTRICT` y `ON UPDATE RESTRICT`. No se utilizan `CASCADE` ni `SET NULL` automáticos. La nulabilidad de las columnas FK depende exclusivamente de la matriz de atributos (sección 8.3), no de la acción referencial.

> **Nulabilidad en FKs compuestas.** La FK `ACTIVIDAD (id_proyecto, id_usuario)` solo se evalúa cuando `id_proyecto` no es NULL. La FK simple `ACTIVIDAD.id_usuario` se evalúa siempre, por lo que una actividad independiente conserva propietario obligatorio.

### 9.3. Claves únicas

| Tabla | Clave única | Motivo |
|---|---|---|
| `USUARIO` | `correo` | Evitar cuentas duplicadas. |
| `REGISTRO_USUARIO` | `id_usuario` | Un registro por usuario. |
| `PERFIL_KIRO` | `id_usuario` | Un perfil por usuario. |
| `CATEGORIA` | `(id_categoria, id_usuario)` | Destino de la FK compuesta. No cambia la cardinalidad: `id_categoria` ya es PK. |
| `PROYECTO` | `(id_proyecto, id_usuario)` | Destino de la FK compuesta de actividades. No cambia la cardinalidad: `id_proyecto` ya es PK. |

> **Efecto de la collation en `USUARIO.correo`.** La UQ de `correo` se evalúa con `utf8mb4_unicode_ci` (sección 8.1.2): la comparación **no distingue mayúsculas ni acentos**. Por tanto, dos correos que solo difieran en mayúsculas o en acentos se consideran duplicados y el segundo será rechazado.

> **Recomendación pendiente, no aprobada:** `UQ(id_usuario, nombre)` en `CATEGORIA` para evitar nombres repetidos del mismo usuario. No forma parte de las restricciones aprobadas y solo se implementará si el negocio lo confirma. Mientras no se apruebe, la FK de `CATEGORIA.id_usuario` necesitará un índice propio que comience por `id_usuario` (ver sección 10).

### 9.4. Restricciones de integridad

**Aprobadas:**

- `USUARIO.hash_contrasena` es obligatorio y nunca almacena texto plano.
- `ACTIVIDAD.id_usuario` es obligatorio.
- `ACTIVIDAD.id_proyecto` puede ser NULL.
- `NOTA.id_categoria` y `RECURSO.id_categoria` pueden ser NULL; la FK compuesta no se aplica en ese caso.
- `REGISTRO_USUARIO.fecha_verificacion` puede ser NULL: una cuenta puede estar registrada sin verificación completada.
- `INICIO_SESION.fecha_fin` puede ser NULL: una sesión activa todavía no tiene fecha de finalización.
- La FK compuesta de actividad impide asociar una actividad a un proyecto de otro usuario.
- Las FKs compuestas de categoría impiden usar categorías de otro usuario.
- `HISTORIAL_ACCION.id_registro_afectado` admite NULL.
- Todas las FKs usan `ON DELETE RESTRICT` y `ON UPDATE RESTRICT`; no se usan `CASCADE` ni `SET NULL` automáticos.
- `HISTORIAL_ACCION` es de solo inserción para el usuario de aplicación.
- La creación de `USUARIO`, `REGISTRO_USUARIO` y `PERFIL_KIRO` es transaccional, con alta de usuarios centralizada y permisos de inserción controlados.
- Las operaciones relevantes y su registro en `HISTORIAL_ACCION` son atómicos en la misma transacción.

**Recomendadas, sujetas a validación (ninguna aprobada):**

- `CITA.duracion_minutos` mayor que cero.
- Coherencia entre `PROYECTO.fecha_inicio` y `PROYECTO.fecha_fin`: condición pendiente de confirmación, incluida la validez o no de fechas iguales.
- Coherencia entre `NOTA.fecha_creacion` y `NOTA.fecha_actualizacion`: condición pendiente de confirmación, incluida la validez o no de fechas iguales.
- Coherencia entre `INICIO_SESION.fecha_inicio` y `INICIO_SESION.fecha_fin`: condición pendiente de confirmación, incluida la validez o no de fechas iguales. La nulabilidad de `fecha_fin` ya está aprobada como NULL; la condición debe considerar ese caso.
- Unicidad de `CATEGORIA.nombre` por usuario: **recomendación pendiente**, no aprobada.

**`CHECK`:** MariaDB 10.4.32 admite restricciones `CHECK` y las aplica. Sin embargo, no se incorporan en esta etapa `CHECK` de estados, prioridades, tipos, actor, resultado, tipo de acción ni de coherencia de fechas, porque los dominios y las reglas funcionales siguen pendientes. Su incorporación requiere aprobación previa de esas reglas.

**Pendientes:**

- Restricciones CHECK de estados, prioridades, tipos, actor, resultado, tipo de acción y coherencia de fechas.
- Atributo y mecanismo de eliminación lógica.
- Valores `DEFAULT` de atributos sin valor aprobado (sección 8.4).

### 9.5. Integridad de la auditoría

- `HISTORIAL_ACCION` no tiene FK hacia la entidad afectada.
- La validez de `entidad_afectada` y `id_registro_afectado` se controla en la capa de operaciones o mediante triggers.
- La comprobación de existencia de `id_registro_afectado` debe coordinarse con la operación auditada y su transacción; una validación aislada puede quedar desactualizada si el registro se modifica o elimina antes de insertar la auditoría.
- El mecanismo concreto para cubrir ese riesgo sigue pendiente (sección 7.4); no se implementan triggers en esta etapa.
- El usuario de aplicación no debe poder modificar ni eliminar filas de auditoría.
- La operación auditada y la escritura de auditoría deben ejecutarse en la misma transacción; la operación no se confirma si la auditoría falla. Si se audita un intento fallido, se usa una transacción independiente.
- `actor` debe distinguir el origen de la acción; sus valores están pendientes.

---

## 10. Índices: clasificación por propósito

> MariaDB exige un índice en las columnas hijas de cada FK y otro en las columnas padre referenciadas. Un mismo índice puede cubrir una FK y una consulta; en ese caso es compartido y no se duplica. En un índice compuesto, el orden de las columnas y el prefijo izquierdo determinan qué operaciones puede resolver.

**Estado de implementación:** los 19 índices secundarios descritos en las secciones 10.2 y 10.4 ya están implementados en la base `Kiro`: 5 `UNIQUE` (3 simples y 2 compuestos) y 14 `KEY` (3 simples y 11 compuestos), además de los 12 índices de clave primaria. Los cinco índices candidatos de la sección 10.3 no se implementaron y siguen pendientes de validación con `EXPLAIN`.

### 10.1. Clasificación

| Clasificación | Significado |
|---|---|
| **N-FK** | Necesario para una clave foránea. |
| **N-C** | Necesario para una consulta identificada en este plan. |
| **Compartido** | Cubre a la vez una FK y una consulta identificada. |
| **Candidato** | Índice propuesto cuya consulta concreta o cuya semántica de negocio aún no está definida. No se considera necesario ni aprobado. |

Criterios:

- Un índice con distinto orden de columnas o distinto prefijo izquierdo **no sustituye** a otro.
- Un índice solo se clasifica como **N-C** o **Compartido** cuando la consulta que lo justifica está identificada en este plan o en el README. La utilidad aparente no basta.
- Sin consulta concreta, el índice queda como **candidato pendiente de validación** y no se implementa.
- Los índices de tablas hijas y de tablas padre se documentan por separado.
- Las clasificaciones no aprueban restricciones nuevas; describen el propósito técnico de cada índice.

### 10.2. Índices necesarios en tablas hijas

Solo se incluyen índices con una finalidad definida: cubrir una FK, atender una consulta identificada o ambas.

| Tabla | Índice | Clasificación | Propósito |
|---|---|---|---|
| `REGISTRO_USUARIO` | UQ `(id_usuario)` | **N-FK** | FK a `USUARIO` y máximo un registro por usuario. |
| `PERFIL_KIRO` | UQ `(id_usuario)` | **N-FK** | FK a `USUARIO` y máximo un perfil por usuario. |
| `INICIO_SESION` | `(id_usuario, fecha_inicio)` | **Compartido** | FK y consulta de sesiones de un usuario ordenadas por fecha de inicio (registro de accesos del README). |
| `CITA` | `(id_usuario, fecha_inicio)` | **Compartido** | FK y agenda de un usuario por rango de fechas. |
| `NOTA` | `(id_usuario, fecha_creacion)` | **Compartido** | FK y notas de un usuario ordenadas por fecha de creación. |
| `NOTA` | `(id_categoria, id_usuario)` | **N-FK** | FK compuesta a `CATEGORIA`. |
| `PROYECTO` | `(id_usuario)` | **N-FK** | FK a `USUARIO`. El índice compuesto con `estado` y `fecha_fin` queda como candidato (sección 10.3). |
| `ACTIVIDAD` | `(id_usuario)` | **N-FK** | FK a `USUARIO`. El índice compuesto con `estado` y `fecha_limite` queda como candidato (sección 10.3). |
| `ACTIVIDAD` | `(id_proyecto, id_usuario)` | **N-FK** | FK compuesta a `PROYECTO`. |
| `ACTIVIDAD` | `(id_proyecto, estado, fecha_limite)` | **N-C** | Resumen de actividades de un proyecto por estado y vencimiento (README, módulo de proyectos y actividades). |
| `CATEGORIA` | `(id_usuario)` | **N-FK** | FK a `USUARIO` mientras no se apruebe la UQ `(id_usuario, nombre)`. |
| `RECURSO` | `(id_usuario, fecha_registro)` | **Compartido** | FK y recursos de un usuario ordenados por fecha de registro. |
| `RECURSO` | `(id_categoria, id_usuario)` | **N-FK** | FK compuesta a `CATEGORIA`; con igualdad en ambas columnas también sirve para listar los recursos de una categoría y su usuario. |
| `RECUERDO` | `(id_usuario, fecha_registro)` | **Compartido** | FK y recuerdos de un usuario ordenados por fecha de registro. |
| `HISTORIAL_ACCION` | `(id_usuario, fecha_accion)` | **Compartido** | FK e historial cronológico por usuario. |
| `HISTORIAL_ACCION` | `(entidad_afectada, id_registro_afectado)` | **N-C** | Acciones sobre un registro concreto, coherente con la validación de la auditoría polimórfica. |

Precisiones sobre prefijos y orden:

- `(id_usuario, fecha_inicio)` puede cubrir la FK simple de `CITA.id_usuario` y las búsquedas por usuario y rango de fechas.
- `(id_proyecto, estado, fecha_limite)` no cubre la FK `(id_proyecto, id_usuario)`, porque `id_usuario` no es la segunda columna; el índice N-FK dedicado sigue siendo necesario.
- Ningún índice de una tabla sustituye a otro de otra tabla, aunque compartan nombre de columna; por ejemplo, `(id_usuario, fecha_registro)` en `RECURSO` no cubre la FK ni las consultas de `RECUERDO`.
- `(id_usuario)` en `PROYECTO` y `ACTIVIDAD` es el índice N-FK mínimo mientras los compuestos con `estado` y fecha no estén validados. Si un candidato se aprueba, su prefijo izquierdo `(id_usuario)` permitiría reemplazar el índice simple.

### 10.3. Índices candidatos pendientes de validación

Estos índices **no se consideran necesarios ni aprobados**. Su utilidad depende de consultas que el plan o el README no definen con suficiente concreción, o de dominios que siguen pendientes. No se implementan hasta que se documente la consulta y se valide su plan de ejecución con `EXPLAIN` en MariaDB 10.4.32.

| Tabla | Índice | Situación | Motivo de la clasificación |
|---|---|---|---|
| `INICIO_SESION` | `(estado_sesion, fecha_fin)` | **Candidato pendiente** | No hay una consulta concreta de sesiones por estado y fecha de finalización; además, el dominio de `estado_sesion` está pendiente. |
| `CITA` | `(id_usuario, estado, fecha_inicio)` | **Candidato pendiente** | No hay una consulta identificada que filtre la agenda por estado. La agenda por usuario y fecha ya está cubierta por `(id_usuario, fecha_inicio)`. |
| `PROYECTO` | `(id_usuario, estado, fecha_fin)` | **Candidato pendiente** | No hay una consulta concreta de proyectos por estado y vencimiento; el dominio de `estado` está pendiente. La FK se cubre con `(id_usuario)`. |
| `ACTIVIDAD` | `(id_usuario, estado, fecha_limite)` | **Candidato pendiente** | No hay una consulta concreta de actividades por propietario, estado y vencimiento; el dominio de `estado` está pendiente. La FK se cubre con `(id_usuario)`. |
| `RECUERDO` | `(id_usuario, autorizado, estado)` | **Candidato pendiente** | Su justificación depende por completo de la semántica aún no definida de `RECUERDO.autorizado` y `RECUERDO.estado` (sección 7.3). |

> Ninguno de estos candidatos sustituye a un índice N-FK ni a uno Compartido ya justificado. Tampoco se aprueban por el hecho de quedar documentados.

### 10.4. Índices en tablas padre

| Tabla padre | Índice | Clasificación | Propósito |
|---|---|---|---|
| `USUARIO` | PK `(id_usuario)` | **Compartido** | Destino de las FKs simples e identificación por PK. |
| `USUARIO` | UQ `(correo)` | **N-C** | Búsqueda de cuenta y autenticación; no es destino de FK. |
| `CATEGORIA` | UQ `(id_categoria, id_usuario)` | **N-FK** | Destino de las FKs compuestas de `NOTA` y `RECURSO`. |
| `PROYECTO` | UQ `(id_proyecto, id_usuario)` | **N-FK** | Destino de la FK compuesta de `ACTIVIDAD`. |

> Las UQ `(id_categoria, id_usuario)` y `(id_proyecto, id_usuario)` no añaden una regla de unicidad nueva, porque `id_categoria` y `id_proyecto` ya son PK. Existen para habilitar las FKs compuestas y no alteran las cardinalidades.

### 10.5. Índices no propuestos en esta etapa

- `HISTORIAL_ACCION (tipo_accion)` de forma aislada: no hay una consulta identificada que lo justifique. Si se necesita filtrar por tipo, se evaluará un índice compuesto que incluya `fecha_accion` y se validará con `EXPLAIN`.
- Índices de texto completo sobre `NOTA.contenido` o `RECUERDO.contenido`: no hay caso de uso definido; no se proponen.
- `CATEGORIA (id_usuario, nombre)`: **recomendación pendiente, no aprobada**. Si se aprueba la unicidad, sería un índice compartido (FK y búsqueda por nombre) y reemplazaría al índice N-FK `(id_usuario)`.

### 10.6. Reglas para evitar duplicados y redundancias

1. No se crea un índice para una PK ni para columnas ya cubiertas por una UQ: MariaDB ya las indexa.
2. No se crea un índice sobre `id_usuario` si existe otro cuyo prefijo izquierdo sea `id_usuario`.
3. Cada FK debe quedar cubierta por al menos un índice con sus columnas en el orden exacto de la FK.
4. `(id_usuario, fecha_inicio)` y `(id_usuario, estado, fecha_inicio)` no son intercambiables; el segundo solo se consideraría si se aprueba como candidato.
5. Un índice que comienza por `id_proyecto` pero no continúa con `id_usuario` no satisface la FK compuesta de `ACTIVIDAD`.
6. Los índices N-C y los candidatos se validan con `EXPLAIN` sobre consultas reales antes de crearlos; los candidatos requieren además que su consulta se documente primero.
7. Se revisará la redundancia entre índices de la misma tabla después de las pruebas. Si un candidato con prefijo `(id_usuario)` se aprueba, reemplazará al índice N-FK simple `(id_usuario)` de esa tabla.
8. Ningún candidato se implementa por analogía con otra tabla ni por utilidad aparente.

---

## 11. Orden recomendado de creación de tablas

1. `USUARIO`
2. `REGISTRO_USUARIO`
3. `PERFIL_KIRO`
4. `INICIO_SESION`
5. `CATEGORIA`
6. `PROYECTO`
7. `NOTA`
8. `RECURSO`
9. `ACTIVIDAD`
10. `CITA`
11. `RECUERDO`
12. `HISTORIAL_ACCION`

**Justificación:**

- `USUARIO` no depende de ninguna otra entidad.
- `REGISTRO_USUARIO`, `PERFIL_KIRO` e `INICIO_SESION` dependen de `USUARIO`.
- `CATEGORIA` depende de `USUARIO` y debe existir antes de `NOTA` y `RECURSO`.
- `PROYECTO` depende de `USUARIO` y debe existir antes de `ACTIVIDAD`.
- `NOTA` y `RECURSO` usan la FK compuesta de categoría.
- `ACTIVIDAD` usa las FKs de usuario y proyecto.
- `CITA` y `RECUERDO` dependen de `USUARIO`.
- `HISTORIAL_ACCION` se crea al final por preferencia organizativa, para facilitar la incorporación posterior de los mecanismos de auditoría una vez que las tablas auditadas ya existen.
- Esa posición **no es una dependencia obligatoria de claves foráneas**: la referencia polimórfica de `HISTORIAL_ACCION` no utiliza una FK convencional hacia la entidad afectada. Su única FK es `id_usuario` hacia `USUARIO`, que ya existe desde el primer paso.

> La ubicación de `HISTORIAL_ACCION` al final del orden puede ajustarse sin alterar las dependencias reales del esquema, siempre que se mantenga después de `USUARIO`.

---

## 12. Plan de pruebas y validación

### 12.1. Validación estructural

- Confirmar la existencia de las 12 tablas.
- Confirmar que cada tabla tiene su PK.
- Confirmar que todas las FK apuntan a columnas existentes y del mismo tipo.
- Confirmar las UQ de `USUARIO.correo`, `REGISTRO_USUARIO.id_usuario` y `PERFIL_KIRO.id_usuario`.
- Confirmar las UQ compuestas `CATEGORIA (id_categoria, id_usuario)` y `PROYECTO (id_proyecto, id_usuario)`, necesarias para las FKs compuestas.
- Confirmar que cada FK está cubierta por un índice con sus columnas en el orden correcto.
- Confirmar que existen 14 FKs: 11 simples y 3 compuestas (`NOTA`, `RECURSO` y `ACTIVIDAD`).
- Confirmar la nulabilidad aprobada de `ACTIVIDAD.id_proyecto`, `NOTA.id_categoria`, `RECURSO.id_categoria`, `HISTORIAL_ACCION.id_registro_afectado`, `REGISTRO_USUARIO.fecha_verificacion` e `INICIO_SESION.fecha_fin`.
- Confirmar que no queda ninguna nulabilidad pendiente en la sección 8.3.
- Confirmar que `ACTIVIDAD.id_usuario` es NOT NULL aunque `id_proyecto` sea NULL.
- Confirmar `utf8mb4` y `utf8mb4_unicode_ci` en la base de datos y en las tablas.
- Confirmar que todas las FKs declaran `ON DELETE RESTRICT` y `ON UPDATE RESTRICT`.
- Confirmar que `AUTO_INCREMENT` está presente solo en las PK numéricas.
- Confirmar la versión real del servidor y que corresponde a MariaDB 10.4.32 con InnoDB.
- Confirmar que no existen tablas ni entidades adicionales.

### 12.2. Integridad referencial

| Caso | Resultado esperado |
|---|---|
| Insertar dos usuarios con el mismo correo. | Rechazo por UQ. |
| Insertar dos usuarios cuyo correo solo difiera en mayúsculas o acentos. | Rechazo por UQ con `utf8mb4_unicode_ci`. |
| Insertar dos `REGISTRO_USUARIO` para el mismo usuario. | Rechazo por UQ. |
| Insertar dos `PERFIL_KIRO` para el mismo usuario. | Rechazo por UQ. |
| Insertar una nota con una categoría de otro usuario. | Rechazo por FK compuesta. |
| Insertar un recurso con una categoría de otro usuario. | Rechazo por FK compuesta. |
| Insertar una nota o recurso sin categoría. | Aceptación; `id_categoria` NULL. |
| Insertar una actividad independiente sin `id_usuario`. | Rechazo por NOT NULL, aunque `id_proyecto` sea NULL. |
| Insertar una actividad con `id_proyecto` NULL y un `id_usuario` inexistente. | Rechazo por la FK `id_usuario`; la FK compuesta no se evalúa, pero el propietario sí se valida. |
| Insertar una actividad con un proyecto de otro usuario. | Rechazo por FK compuesta. |
| Insertar una actividad independiente con `id_usuario`. | Aceptación; `id_proyecto` NULL. |
| Insertar una auditoría con `id_registro_afectado` NULL. | Aceptación, si la acción no tiene registro concreto. |
| Insertar una auditoría con una entidad no permitida. | Rechazo por validación de aplicación o mecanismo controlado. |
| Eliminar un `USUARIO` con registros dependientes. | Rechazo por `ON DELETE RESTRICT`. |
| Actualizar el `id_usuario` de un `USUARIO` referenciado. | Rechazo por `ON UPDATE RESTRICT`. |
| Insertar un `REGISTRO_USUARIO` sin `fecha_verificacion`. | Aceptación; `fecha_verificacion` NULL. |
| Insertar un `INICIO_SESION` sin `fecha_fin`. | Aceptación; `fecha_fin` NULL. |

### 12.3. Transacciones

- Crear `USUARIO`, `REGISTRO_USUARIO` y `PERFIL_KIRO` en una sola transacción.
- Forzar un fallo en el perfil y verificar que no queda un usuario parcial.
- Crear una actividad y asociarla a un proyecto del mismo usuario.
- Reasignar una actividad a otro proyecto del mismo usuario.
- Intentar reasignarla a un proyecto de otro usuario y verificar el rechazo.
- Registrar una operación y su auditoría en la misma transacción.
- Verificar que un fallo de auditoría revierte la operación auditada.
- Verificar que un intento fallido que deba auditarse se registra en una transacción independiente.
- Diseñar y probar la estrategia de serialización y bloqueo para evitar solapamientos de citas (RN-07), considerando los índices disponibles; no se considera garantizada en esta etapa.

### 12.4. Autenticación y sesiones

- Verificar que `hash_contrasena` almacena un hash y no la contraseña original.
- Probar el registro y los estados de verificación cuando se definan sus dominios.
- Comprobar `fecha_verificacion` frente al estado de verificación cuando se defina el dominio de este; su nulabilidad está aprobada como NULL.
- Comprobar que una sesión activa puede tener `INICIO_SESION.fecha_fin` NULL.
- Comprobar la condición de coherencia que se apruebe entre `INICIO_SESION.fecha_inicio` y `fecha_fin`, incluido el caso de `fecha_fin` NULL; la validez de fechas iguales está pendiente.
- Verificar que un usuario no pueda consultar sesiones de otro.

### 12.5. Auditoría

- Confirmar que el usuario de aplicación puede insertar auditoría.
- Confirmar que no puede actualizar ni eliminar filas de auditoría.
- Confirmar que `entidad_afectada` pertenece a la lista controlada.
- Confirmar que una referencia no nula a `id_registro_afectado` corresponde a un registro existente.
- Confirmar que la auditoría conserva `actor`, `fecha_accion`, `tipo_accion` y `resultado`.
- Verificar el comportamiento con `id_registro_afectado` NULL.

### 12.6. Rendimiento

> Los `EXPLAIN` se ejecutan sobre MariaDB 10.4.32. Ningún índice garantiza por sí solo un plan de ejecución: debe comprobarse la utilización real del índice, el tipo de acceso y la ausencia de escaneos completos u ordenamientos innecesarios.

**Estado:** las comprobaciones con `EXPLAIN` siguen pendientes en `Kiro`. La práctica realizada en `db_ecommerce` es independiente y no constituye evidencia de rendimiento para esta base de datos.

**Consultas con índice identificado (N-C o Compartido):**

- Agenda de un usuario por rango de fechas: `CITA (id_usuario, fecha_inicio)`.
- Notas de un usuario ordenadas por fecha de creación: `NOTA (id_usuario, fecha_creacion)`.
- Actividades de un proyecto por estado y fecha límite: `ACTIVIDAD (id_proyecto, estado, fecha_limite)`.
- Recursos de una categoría y su usuario, con igualdad en ambas columnas: `RECURSO (id_categoria, id_usuario)`.
- Recursos de un usuario ordenados por fecha de registro: `RECURSO (id_usuario, fecha_registro)`.
- Recuerdos de un usuario ordenados por fecha de registro: `RECUERDO (id_usuario, fecha_registro)`.
- Sesiones de un usuario ordenadas por fecha de inicio: `INICIO_SESION (id_usuario, fecha_inicio)`.
- Historial de un usuario ordenado por fecha: `HISTORIAL_ACCION (id_usuario, fecha_accion)`.
- Acciones sobre una entidad y un registro concretos: `HISTORIAL_ACCION (entidad_afectada, id_registro_afectado)`.
- Búsqueda de cuenta por correo: `USUARIO (correo)`.

**Consultas candidatas (solo después de definir la consulta y validar el índice):**

- Sesiones por estado y fecha de finalización: `INICIO_SESION (estado_sesion, fecha_fin)`; depende del dominio de `estado_sesion`.
- Citas de un usuario filtradas por estado y ordenadas por fecha: `CITA (id_usuario, estado, fecha_inicio)`.
- Proyectos de un usuario por estado y fecha de finalización: `PROYECTO (id_usuario, estado, fecha_fin)`.
- Actividades de un usuario por estado y fecha límite: `ACTIVIDAD (id_usuario, estado, fecha_limite)`.
- Recuerdos de un usuario por autorización y estado: `RECUERDO (id_usuario, autorizado, estado)`; bloqueado por la semántica pendiente de `autorizado` y `estado`.

**Comprobaciones comunes:**

- Confirmar que cada consulta usa las columnas del índice en su orden o en un prefijo izquierdo válido.
- Confirmar que el plan no declara un índice nuevo solo porque el resultado sea aceptable.
- Confirmar que no hay escaneos completos ni ordenamientos temporales evitables en las consultas anteriores.
- Registrar el plan observado y la versión del servidor utilizado.
- Revisar índices redundantes después de las pruebas.

### 12.7. Recuperación y respaldo

- Documentar una estrategia de respaldo.
- Restaurar una copia en un entorno de prueba.
- Verificar la integridad referencial después de la restauración.
- Verificar que la auditoría y los datos de configuración se conservan.

### 12.8. Criterios de aceptación

- Las 12 entidades existen y no hay entidades adicionales.
- Las decisiones aprobadas están implementadas.
- Las FKs compuestas impiden cruces de usuario.
- Las actividades independientes tienen propietario.
- La creación de usuarios está centralizada y los permisos de inserción están controlados.
- La auditoría es de solo inserción para la aplicación y atómica con la operación auditada.
- Cada FK está cubierta por un índice y no hay índices duplicados.
- Los índices candidatos no se implementaron sin consulta documentada ni validación con `EXPLAIN`.
- Las decisiones pendientes siguen documentadas y no se implementaron por suposición.
- RN-07 no se declara garantizada: su estrategia de concurrencia queda pendiente de especificación y prueba.
- Las consultas principales usan índices adecuados.
- Las pruebas de transacción y recuperación son reproducibles.

---

## 13. Matriz de trazabilidad con las reglas de negocio del README

| Regla | Cómo la apoya el plan | Estado |
|---|---|---|
| **RN-01.** Usuario y KIRO trabajan sobre los mismos registros; no hay copias paralelas. | Un único esquema y un único conjunto de tablas; las operaciones de usuario y KIRO usan los mismos registros. | Diseño cubierto. |
| **RN-02.** Toda operación de KIRO pasa por una herramienta definida; no hay acceso directo a la base de datos. | El backend accede con PDO y permisos limitados; KIRO no recibe credenciales. | Arquitectura y seguridad. |
| **RN-03.** Los datos obligatorios se validan antes de registrar o modificar. | NOT NULL, PK, FK, UQ y validación de aplicación; MariaDB 10.4.32 admite `CHECK`, pero los dominios y reglas siguen pendientes, por lo que no se incorporan todavía. | Parcial; dominios pendientes. |
| **RN-04.** Las operaciones sensibles requieren confirmación explícita. | Se implementa en la capa de operaciones; la auditoría registra el resultado. | Capa de aplicación. |
| **RN-05.** Toda operación relevante queda registrada en `HISTORIAL_ACCION` con autor, fecha, acción y resultado. | `actor`, `fecha_accion`, `tipo_accion` y `resultado`; auditoría de solo inserción y atómica con la operación auditada. | Decisión aprobada. |
| **RN-06.** La memoria es configurable y el usuario puede revisar, desactivar o eliminar recuerdos autorizados. | `PERFIL_KIRO.memoria_activa` y `RECUERDO.autorizado`; la semántica exacta está pendiente. | Soporte de esquema; semántica pendiente. |
| **RN-07.** Una cita no puede ocupar un horario ya reservado. | El fin se calcula con `fecha_inicio` y `duracion_minutos`; la comprobación debe contemplar la concurrencia y requiere una estrategia de serialización y bloqueo diseñada según los índices disponibles. La estrategia concreta no está especificada. | **Pendiente de especificación técnica.** |
| **RN-08.** Una actividad pertenece a un proyecto o es independiente, nunca a ambos estados. | `ACTIVIDAD.id_proyecto` nullable y `ACTIVIDAD.id_usuario` obligatorio; FK compuesta para el mismo propietario. | Decisión aprobada. |
| **RN-09.** Eliminación lógica y recuperación; eliminación definitiva excepcional y confirmada. | No se implementa hasta definir la política y el atributo correspondiente. | Pendiente. |
| **RN-10.** Las integraciones externas son opcionales y no desplazan el propósito principal. | Fuera del alcance de la base de datos; no se modelan integraciones externas. | Sin impacto en el esquema. |

---

## 14. Checklist de revisión y aprobación

- [ ] Aprobar este documento como plan definitivo de base de datos.
- [x] Confirmar que las 12 entidades son las oficiales y que no se agregarán ni eliminarán entidades.
- [x] Confirmar `USUARIO.hash_contrasena VARCHAR(255) NOT NULL`.
- [x] Confirmar `ACTIVIDAD.id_usuario INT NOT NULL` y `id_proyecto` nullable.
- [x] Confirmar la FK compuesta `(id_proyecto, id_usuario)`.
- [x] Confirmar las FKs compuestas `(id_categoria, id_usuario)` en `NOTA` y `RECURSO`.
- [x] Confirmar la referencia polimórfica de auditoría y `id_registro_afectado` nullable.
- [x] Confirmar la creación transaccional de `USUARIO`, `REGISTRO_USUARIO` y `PERFIL_KIRO`, con la creación de usuarios centralizada y los permisos de inserción controlados.
- [ ] Definir el mecanismo que garantice funcionalmente la existencia de `REGISTRO_USUARIO` y `PERFIL_KIRO` por usuario (sección 7.6).
- [x] Confirmar que la operación auditada y su auditoría son atómicas en la misma transacción.
- [x] Confirmar la matriz de nulabilidad de la sección 8.3: 82 atributos, 6 decisiones NULL y 2 NOT NULL aprobadas, sin pendientes.
- [x] Confirmar `ON DELETE RESTRICT` y `ON UPDATE RESTRICT` en todas las FKs.
- [x] Confirmar `AUTO_INCREMENT` en las PK numéricas de las 12 entidades, nunca en columnas que no sean PK.
- [x] Confirmar charset `utf8mb4` y collation `utf8mb4_unicode_ci`.
- [ ] Confirmar el nombre de la base para entornos futuros; la implementación local usa `Kiro`.
- [x] Confirmar en el script canónico `database/KIRO_MariaDB.sql` los 19 índices secundarios (5 `UNIQUE`: 3 simples y 2 compuestos; 14 `KEY`: 3 simples y 11 compuestos) y los 12 índices de clave primaria. *Evidencia estática del DDL; no sustituye la comprobación con `SHOW INDEX`.*
- [ ] Comprobar con `SHOW INDEX` en la base `Kiro` esos 19 índices secundarios y los 12 de clave primaria, y con `SHOW TABLE STATUS` el motor InnoDB. *Verificación en servidor pendiente de evidencia registrada.*
- [ ] Decidir cuáles de los índices candidatos de la sección 10.3 se validan con `EXPLAIN` e implementan.
- [x] Confirmar en el script canónico que las 12 tablas declaran `ENGINE=InnoDB`. *Evidencia estática de las cláusulas `ENGINE`; la versión del servidor no puede comprobarse en el archivo.*
- [ ] Verificar en el servidor, con `SELECT VERSION()`, que la versión es MariaDB 10.4.32. *Pendiente de evidencia registrada.*
- [ ] Definir la política de eliminación lógica y definitiva (RN-09) y su atributo.
- [ ] Definir los dominios de estados, prioridades, tipos, actor, resultado y tipo de acción, y decidir sus `CHECK`.
- [ ] Confirmar la semántica de `PERFIL_KIRO.memoria_activa`, `RECUERDO.autorizado` y `RECUERDO.estado`.
- [ ] Confirmar el mecanismo de validación de la auditoría polimórfica.
- [ ] Definir las condiciones de coherencia de fechas y la validez o no de fechas iguales (secciones 6.6 y 9.4).
- [ ] Especificar y probar la estrategia de concurrencia y bloqueo para evitar solapamientos de citas (RN-07).
- [ ] Decidir la unicidad de `CATEGORIA.nombre` por usuario, que sigue siendo una recomendación pendiente.
- [ ] Definir los valores `DEFAULT` de `PERFIL_KIRO.memoria_activa`, `RECUERDO.autorizado` y demás atributos sin valor aprobado (sección 8.4).
- [ ] Definir la zona horaria de la aplicación y del servidor.
- [x] Confirmar en el script canónico la definición de las 12 tablas, sus 12 claves primarias, 14 claves foráneas y 19 índices secundarios. *Evidencia estática del DDL.*
- [x] Confirmar en el script canónico las 120 tuplas de datos de prueba, 10 por tabla (12 bloques `INSERT`). *Evidencia estática.*
- [ ] Verificar en el servidor la creación de las 12 tablas con `SHOW TABLE STATUS` y la carga de 120 registros con `SELECT COUNT(*)` por tabla. *Pendiente de evidencia registrada.*
- [ ] Aprobar la revisión técnica completa de este plan.

> **Fin del plan.** Las 12 tablas, sus restricciones, los 19 índices secundarios y los datos de prueba ya se implementaron en la base `Kiro` mediante `database/KIRO_MariaDB.sql`. Las vistas, los procedimientos, las funciones, los triggers, las transacciones y los mecanismos de auditoría se implementarán en una etapa posterior, después de revisar y aprobar este documento.
