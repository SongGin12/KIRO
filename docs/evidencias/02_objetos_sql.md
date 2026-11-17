# Evidencia 02 - Objetos SQL implementados (13)

- Servidor: MariaDB 10.4.32-MariaDB
- Fecha de generacion: 2026-11-16 18:57
- Metodo: catalogo de information_schema (lectura). Las definiciones completas fueron verificadas previamente contra SHOW CREATE, coincidencia 13/13.

## Vistas (4)

| Vista |
|---|
| vw_kiro_actividades_pendientes |
| vw_kiro_notas_categorias |
| vw_kiro_proximas_citas |
| vw_kiro_proyectos_activos |

## Funciones almacenadas (5)

| Funcion | Tipo de retorno |
|---|---|
| fn_calcular_fecha_fin_cita | datetime |
| fn_total_actividades_pendientes | int(11) |
| fn_total_notas_usuario | int(11) |
| fn_total_proyectos_activos | int(11) |
| fn_total_recursos_usuario | int(11) |

## Procedimientos almacenados (2)

| Procedimiento |
|---|
| sp_registrar_cita_segura |
| sp_resumir_actividades_usuario |

## Triggers (2)

| Trigger | Momento | Evento | Tabla |
|---|---|---|---|
| trg_auditoria_actividad | AFTER | UPDATE | actividad |
| trg_validar_actividad | BEFORE | INSERT | actividad |

## Proposito de cada objeto

- vw_kiro_proximas_citas: citas futuras de un usuario, excluyendo las canceladas.
- vw_kiro_actividades_pendientes: actividades pendientes o en progreso, con su proyecto.
- vw_kiro_proyectos_activos: proyectos en progreso, con prioridad y fecha de fin.
- vw_kiro_notas_categorias: notas de un usuario junto a su categoria.
- fn_total_actividades_pendientes / fn_total_proyectos_activos / fn_total_notas_usuario / fn_total_recursos_usuario: conteos por usuario.
- fn_calcular_fecha_fin_cita: fecha y hora de fin de una cita (inicio + duracion).
- sp_registrar_cita_segura: alta segura de cita con validacion, control de solapamientos y transaccion (COMMIT/ROLLBACK).
- sp_resumir_actividades_usuario: recorrido con cursor y resumen de actividades por estado.
- trg_validar_actividad: BEFORE INSERT sobre ACTIVIDAD; valida titulo, descripcion y fecha limite.
- trg_auditoria_actividad: AFTER UPDATE sobre ACTIVIDAD; registra la actualizacion en HISTORIAL_ACCION con estado anterior y nuevo.
