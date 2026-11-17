# Evidencia 01 - Tablas y conteos de Kiro

- Servidor: MariaDB 10.4.32-MariaDB
- Fecha de generacion: 2026-11-16 18:57
- Metodo: consultas de lectura (information_schema + SELECT COUNT(*)). No se modifico ningun dato.
- Nota: CITA e HISTORIAL_ACCION tienen 11 filas porque incluyen 1 registro adicional producto de las pruebas del laboratorio (SP de citas y trigger de auditoria). Las demas tablas conservan sus 10 registros semilla.

| Tabla | Motor | Collation | Filas (COUNT(*)) |
|---|---|---|---|
| actividad | InnoDB | utf8mb4_unicode_ci | 10 |
| categoria | InnoDB | utf8mb4_unicode_ci | 10 |
| cita | InnoDB | utf8mb4_unicode_ci | 11 |
| historial_accion | InnoDB | utf8mb4_unicode_ci | 11 |
| inicio_sesion | InnoDB | utf8mb4_unicode_ci | 10 |
| nota | InnoDB | utf8mb4_unicode_ci | 10 |
| perfil_kiro | InnoDB | utf8mb4_unicode_ci | 10 |
| proyecto | InnoDB | utf8mb4_unicode_ci | 10 |
| recuerdo | InnoDB | utf8mb4_unicode_ci | 10 |
| recurso | InnoDB | utf8mb4_unicode_ci | 10 |
| registro_usuario | InnoDB | utf8mb4_unicode_ci | 10 |
| usuario | InnoDB | utf8mb4_unicode_ci | 10 |

**Total de filas:** 122 registros.

Las 12 tablas son InnoDB con collation utf8mb4_unicode_ci.
