# Evidencia 04 - Estructura e integridad (PK, FK, indices)

- Servidor: MariaDB 10.4.32-MariaDB
- Fecha de generacion: 2026-11-16 18:57
- Metodo: catalogo de information_schema (lectura).

## Claves primarias (12)

| Tabla | Columnas de la PK |
|---|---|
| actividad | id_actividad |
| categoria | id_categoria |
| cita | id_cita |
| historial_accion | id_accion |
| inicio_sesion | id_sesion |
| nota | id_nota |
| perfil_kiro | id_perfil |
| proyecto | id_proyecto |
| recuerdo | id_recuerdo |
| recurso | id_recurso |
| registro_usuario | id_registro |
| usuario | id_usuario |

## Claves foraneas (14)

| Restriccion | Tabla | Columnas | Referencia |
|---|---|---|---|
| fk_actividad_proyecto_usuario | actividad | id_proyecto, id_usuario | proyecto(id_proyecto, id_usuario) |
| fk_actividad_usuario | actividad | id_usuario | usuario(id_usuario) |
| fk_categoria_usuario | categoria | id_usuario | usuario(id_usuario) |
| fk_cita_usuario | cita | id_usuario | usuario(id_usuario) |
| fk_historial_accion_usuario | historial_accion | id_usuario | usuario(id_usuario) |
| fk_inicio_sesion_usuario | inicio_sesion | id_usuario | usuario(id_usuario) |
| fk_nota_categoria_usuario | nota | id_categoria, id_usuario | categoria(id_categoria, id_usuario) |
| fk_nota_usuario | nota | id_usuario | usuario(id_usuario) |
| fk_perfil_kiro_usuario | perfil_kiro | id_usuario | usuario(id_usuario) |
| fk_proyecto_usuario | proyecto | id_usuario | usuario(id_usuario) |
| fk_recuerdo_usuario | recuerdo | id_usuario | usuario(id_usuario) |
| fk_recurso_categoria_usuario | recurso | id_categoria, id_usuario | categoria(id_categoria, id_usuario) |
| fk_recurso_usuario | recurso | id_usuario | usuario(id_usuario) |
| fk_registro_usuario_usuario | registro_usuario | id_usuario | usuario(id_usuario) |

## Indices secundarios (19)

| Tabla | Indice | Columnas | Unico |
|---|---|---|---|
| actividad | ix_actividad_proyecto_estado_fecha | id_proyecto, estado, fecha_limite | No |
| actividad | ix_actividad_proyecto_usuario | id_proyecto, id_usuario | No |
| actividad | ix_actividad_usuario | id_usuario | No |
| categoria | ix_categoria_usuario | id_usuario | No |
| categoria | uq_categoria_id_usuario | id_categoria, id_usuario | Si (UNIQUE) |
| cita | ix_cita_usuario_fecha | id_usuario, fecha_inicio | No |
| historial_accion | ix_historial_entidad_registro | entidad_afectada, id_registro_afectado | No |
| historial_accion | ix_historial_usuario_fecha | id_usuario, fecha_accion | No |
| inicio_sesion | ix_inicio_sesion_usuario_fecha | id_usuario, fecha_inicio | No |
| nota | ix_nota_categoria_usuario | id_categoria, id_usuario | No |
| nota | ix_nota_usuario_fecha_creacion | id_usuario, fecha_creacion | No |
| perfil_kiro | uq_perfil_kiro_usuario | id_usuario | Si (UNIQUE) |
| proyecto | ix_proyecto_usuario | id_usuario | No |
| proyecto | uq_proyecto_id_usuario | id_proyecto, id_usuario | Si (UNIQUE) |
| recuerdo | ix_recuerdo_usuario_fecha | id_usuario, fecha_registro | No |
| recurso | ix_recurso_categoria_usuario | id_categoria, id_usuario | No |
| recurso | ix_recurso_usuario_fecha | id_usuario, fecha_registro | No |
| registro_usuario | uq_registro_usuario | id_usuario | Si (UNIQUE) |
| usuario | uq_usuario_correo | correo | Si (UNIQUE) |

Total: 19 indices secundarios (5 UNIQUE y 14 KEY), ademas de los 12 indices de clave primaria.
