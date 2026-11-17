# Evidencia 03 - Roles y permisos de la aplicacion

- Servidor: MariaDB 10.4.32-MariaDB
- Fecha de generacion: 2026-11-16 18:57
- Metodo: SHOW GRANTS (lectura). Se omiten hashes de contrasena: la salida del usuario fue expurgada, sustituyendo el hash por el marcador <HASH-OCULTO>.

## Rol rol_kiro_app

```sql
GRANT USAGE ON *.* TO `rol_kiro_app`
GRANT SELECT ON `kiro`.`perfil_kiro` TO `rol_kiro_app`
GRANT SELECT ON `kiro`.`usuario` TO `rol_kiro_app`
GRANT SELECT ON `kiro`.`proyecto` TO `rol_kiro_app`
GRANT SELECT ON `kiro`.`cita` TO `rol_kiro_app`
GRANT SELECT ON `kiro`.`actividad` TO `rol_kiro_app`
```

## Usuario kiro_app@127.0.0.1

```sql
GRANT `rol_kiro_app` TO `kiro_app`@`127.0.0.1`
GRANT USAGE ON *.* TO `kiro_app`@`127.0.0.1` IDENTIFIED BY PASSWORD '<HASH-OCULTO>'
SET DEFAULT ROLE `rol_kiro_app` FOR `kiro_app`@`127.0.0.1`
```

## Lectura de la evidencia

- El rol recibe unicamente GRANT SELECT sobre las cinco tablas que consulta la aplicacion (usuario, perfil_kiro, cita, actividad, proyecto) y USAGE global.
- El usuario tiene USAGE global, el rol asignado y el rol establecido como predeterminado (SET DEFAULT ROLE).
- No se conceden INSERT, UPDATE, DELETE, CREATE ni EXECUTE: la etapa actual de la aplicacion es de solo lectura.
- La linea del usuario que declara la identificacion se muestra con el hash oculto por seguridad.
- La documentacion reproducible de estos permisos vive en database/objetos/05_permisos.sql, sin credenciales.
