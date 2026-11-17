# Evidencia 10 - Seguridad: demostracion de REVOKE con rol de laboratorio

- Servidor: MariaDB 10.4.32-MariaDB, base `Kiro`
- Fecha de la prueba: 2026-11-16
- Script reproducible: `database/consultas/QUERY_04_seguridad_revoke.sql` (ejecutado de punta a punta, exit 0, con `mysql.exe --default-character-set=utf8mb4 -t`)
- Metodo: el ciclo GRANT -> SHOW GRANTS -> REVOKE -> SHOW GRANTS -> DROP ROLE se realizo EXCLUSIVAMENTE sobre el rol de laboratorio `rol_labo_revoke`, sin crear ningun usuario de laboratorio y sin generar contrasenas. La retirada se demostro con `SHOW GRANTS` (catalogo), sin provocar errores intencionales. No se modifico `kiro_app`, ni `rol_kiro_app`, ni ningun permiso real de KIRO; las guardias de comparacion lo demuestran.

## 1. Objetivo academico

Cubrir la parte de seguridad de la asignatura que la evidencia 03 no alcanza: la evidencia 03 demuestra `GRANT` (concesion de minimo privilegio); esta evidencia demuestra `REVOKE` (retirada), completando el ciclo de administracion de privilegios, con verificacion catalogada en cada paso.

## 2. Reglas de aislamiento de la prueba

| Regla | Cumplimiento |
|---|---|
| Usar solo el rol de laboratorio `rol_labo_revoke` | Si; creado y eliminado dentro de la misma sesion de script |
| No crear usuarios de laboratorio ni contrasenas | Si; solo se opero con roles |
| No provocar errores intencionales | Si; ninguna prueba funcional con login fue ejecutada (opcion B aprobada) |
| No modificar `kiro_app` ni `rol_kiro_app` | Si; ninguna sentencia de cambio los menciona (solo `SHOW GRANTS` de lectura) |
| No modificar los scripts originales de permisos | Si; `database/objetos/05_permisos.sql` intacto |
| Guardia previa de existencia | Si; `mysql.user` con `User='rol_labo_revoke'` = 0 antes de crear el rol |
| Guardia de integridad | Si; `CHECKSUM TABLE` de las 12 tablas y conteo total antes y despues |

Nota tecnica: `GRANT` y `REVOKE` modifican unicamente metadatos de privilegios del servidor (tablas del sistema); nunca escriben datos del esquema `Kiro`.

## 3. Estado inicial (baseline) de los permisos reales de KIRO

### Rol `rol_kiro_app` (antes)

```sql
GRANT USAGE ON *.* TO `rol_kiro_app`
GRANT SELECT ON `kiro`.`usuario`        TO `rol_kiro_app`
GRANT SELECT ON `kiro`.`perfil_kiro`    TO `rol_kiro_app`
GRANT SELECT ON `kiro`.`cita`           TO `rol_kiro_app`
GRANT SELECT ON `kiro`.`actividad`      TO `rol_kiro_app`
GRANT SELECT ON `kiro`.`proyecto`       TO `rol_kiro_app`
```

### Usuario `kiro_app@127.0.0.1` (antes)

```sql
GRANT `rol_kiro_app` TO `kiro_app`@`127.0.0.1`
GRANT USAGE ON *.* TO `kiro_app`@`127.0.0.1` IDENTIFIED BY PASSWORD '<HASH-OCULTO>'
SET DEFAULT ROLE `rol_kiro_app` FOR `kiro_app`@`127.0.0.1`
```

(La identificacion se muestra con el marcador por seguridad; el hash real nunca se registra en el repositorio.)

### Contenido de la base (antes)

`CHECKSUM TABLE` de las 12 tablas y conteo total: identicos al baseline historico (usuario 882274266, cita 1030271630, y los 12 valores de la evidencia 08, seccion 3). Total de registros: **122**.

## 4. Ciclo de la demostracion (resultados reales)

| Paso | Operacion SQL | Salida real observada |
|---|---|---|
| 1 | `CREATE ROLE IF NOT EXISTS rol_labo_revoke;` | (rol creado; guardia previa: no existia, conteo 0) |
| 2 | `GRANT SELECT ON `Kiro`.`CITA` TO rol_labo_revoke;` | (privilegio concedido) |
| 3 | `SHOW GRANTS FOR rol_labo_revoke;` | `GRANT USAGE ON *.* TO rol_labo_revoke` + **`GRANT SELECT ON kiro.cita TO rol_labo_revoke`** |
| 4 | `REVOKE SELECT ON `Kiro`.`CITA` FROM rol_labo_revoke;` | (privilegio retirado) |
| 5 | `SHOW GRANTS FOR rol_labo_revoke;` | **solo** `GRANT USAGE ON *.* TO rol_labo_revoke` (el SELECT desaparecio) |
| 6 | `DROP ROLE rol_labo_revoke;` | (rol eliminado, junto con sus asignaciones) |
| 7 | Catalogo: `mysql.user` y `mysql.roles_mapping` con `rol_labo_revoke` | **0 restos** en ambas consultas |

Lectura academica del ciclo: el privilegio concedido en el paso 2 es observable en el catalogo (paso 3); el `REVOKE` del paso 4 lo retira de forma definitiva e inmediata (paso 5: solo queda `USAGE`, el minimo de cualquier cuenta); la eliminacion del rol limpia catalogo y asignaciones sin dejar restos (paso 7).

## 5. Comparacion de permisos: antes vs. despues

| Cuenta | Antes | Despues | Resultado |
|---|---|---|---|
| `rol_kiro_app` | 5 `GRANT SELECT` (usuario, perfil_kiro, cita, actividad, proyecto) + `USAGE` | **Identico** (verificado por `SHOW GRANTS` al final del script) | intacto |
| `kiro_app@127.0.0.1` | rol asignado + `USAGE` + `DEFAULT ROLE` | **Identico** | intacto |
| `rol_labo_revoke` | no existia | no existe (0 restos en catalogo) | limpieza completa |

## 6. Guardias de integridad de la base (antes vs. despues)

`CHECKSUM TABLE` de las 12 tablas reales, medido en la seccion 0 y repetido en la seccion 8 del script: **los 12 valores identicos** entre ambas mediciones y con el baseline historico (usuario 882274266, registro_usuario 3702753872, perfil_kiro 2789492068, inicio_sesion 3551093410, categoria 1926394981, proyecto 1581122082, nota 1901855308, recurso 2631569251, actividad 2584779342, cita 1030271630, recuerdo 4189147891, historial_accion 225788971). Total de registros: **122**. La base `Kiro` no fue modificada.

## 7. Relacion con el modelo de permisos de KIRO

- `rol_kiro_app` sigue demostrando el principio de **minimo privilegio** (evidencia 03): solo `SELECT` sobre las 5 tablas que consulta la aplicacion.
- Esta evidencia anade la pieza administrativa complementaria: si un dia la aplicacion dejara de necesitar un acceso (por ejemplo, al cambiar de etapa), la retirada seria `REVOKE ... FROM rol_kiro_app` y la verificacion con `SHOW GRANTS`, exactamente como se demostro en el laboratorio sin tocar nada real.
- El rol de laboratorio replico la forma de los permisos reales (GRANT SELECT sobre una tabla real del esquema, `Kiro.CITA`), por lo que el patron es representativo del sistema de KIRO.

## 8. Conclusiones y limitaciones

**Conclusiones:**

1. MariaDB 10.4.32 ejecuta el ciclo completo `GRANT` -> `REVOKE` -> `DROP ROLE` y el catalogo (`SHOW GRANTS`, `mysql.user`, `mysql.roles_mapping`) lo refleja de forma inmediata.
2. El `REVOKE` retira el privilegio de forma definitiva e inmediata (el `SHOW GRANTS` posterior ya no lo lista).
3. Los permisos reales de KIRO y el contenido de la base quedaron intactos, verificado por comparacion de grants, checksums y conteos.

**Limitaciones:**

1. Se uso la variante catalogada (opcion B): la retirada se demuestra con `SHOW GRANTS` y no con un intento de acceso fallido del rol de laboratorio; el efecto funcional equivalente esta implcito en la retirada del privilegio.
2. No se creo usuario de laboratorio, por lo que no se demuestra el ciclo completo usuario+rol (`REVOKE rol FROM user`) en este laboratorio; la estructura de asignacion de rol a usuario ya esta documentada y verificada en la evidencia 03 para el caso real.
3. Las pruebas de contrasenas, cifrado de conexion y autenticacion de la aplicacion quedan fuera del alcance de esta evidencia (README, seccion 12: previstas para etapas posteriores).
