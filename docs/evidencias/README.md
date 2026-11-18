# Evidencias de KIRO - paquete de verificaciones

Fecha de generacion: **2026-11-16 18:57**. Servidor: **MariaDB 10.4.32-MariaDB**, base Kiro.

Todas las evidencias se obtuvieron con **consultas exclusivamente de lectura** (SELECT sobre information_schema, SELECT COUNT(*) y SHOW GRANTS). No se modifico ninguna tabla, registro, indice, procedimiento, funcion, vista, trigger, usuario ni permiso. No se ejecutaron instrucciones DDL ni DML.

## Contenido

| Archivo | Evidencia |
|---|---|
| [01_tablas_conteos.md](01_tablas_conteos.md) | Las 12 tablas del esquema con motor, collation y conteo real de filas (122 en total: 120 semilla + 2 de pruebas del laboratorio). |
| [02_objetos_sql.md](02_objetos_sql.md) | Catalogo de los 13 objetos SQL implementados: 4 vistas, 5 funciones, 2 procedimientos y 2 triggers, con su proposito. |
| [03_permisos.md](03_permisos.md) | SHOW GRANTS del rol rol_kiro_app y del usuario kiro_app@127.0.0.1, con el hash de contrasena omitido por seguridad. |
| [04_estructura_integridad.md](04_estructura_integridad.md) | Claves primarias, 14 claves foraneas (con tablas y columnas de referencia) y 19 indices secundarios. |
| [05_analisis_explain.md](05_analisis_explain.md) | Analisis EXPLAIN de 6 consultas representativas (mas 1 complementaria Q2b): acceso por PK, indice unico, JOIN, filtros por usuario/estado/fecha y auditoria, con key_len y Extra por consulta. |
| [06_consultas_avanzadas.md](06_consultas_avanzadas.md) | 8 consultas SQL avanzadas con resultados reales: INNER JOIN, LEFT JOIN, GROUP BY, HAVING, subconsulta escalar, subconsulta IN, CASE y UNION ALL, con lectura de cada resultado. |
| [07_respaldo_restauracion.md](07_respaldo_restauracion.md) | Respaldo logico completo con mysqldump y restauracion verificada en base de prueba independiente; tres intentos documentados (dos fallidos por codificacion, uno correcto), verificacion por bytes y fingerprints, y base original intacta. |
| [08_transacciones_savepoint.md](08_transacciones_savepoint.md) | Transacciones demostradas en tabla temporal de laboratorio: START TRANSACTION, SAVEPOINT, ROLLBACK TO SAVEPOINT (deshacer parcial, conteos 1-2-1), COMMIT y ROLLBACK total; con guardias de CHECKSUM y conteos que demuestran que ninguna tabla real cambio. Script reproducible: database/consultas/QUERY_03_transacciones.sql. |
| [09_pruebas_funciones.md](09_pruebas_funciones.md) | Pruebas consolidadas de las 5 funciones almacenadas, separadas por parametro (4 con id_usuario, 1 con id_cita): contraste esperado/observado contra el SQL equivalente, casos de borde (id inexistente: 0 en conteos, NULL en el calculo de fecha) y uso correcto del id 11 (dominio de CITA, verificado por separado para USUARIO). |
| [10_seguridad_revoke.md](10_seguridad_revoke.md) | Ciclo de administracion de privilegios demostrado con un rol de laboratorio exclusivo: GRANT SELECT, SHOW GRANTS, REVOKE, SHOW GRANTS y DROP ROLE, con verificacion catalogada en cada paso; permisos reales de kiro_app y rol_kiro_app intactos y guardias de CHECKSUM idénticas. Script reproducible: database/consultas/QUERY_04_seguridad_revoke.sql. |
| [11_concurrencia_aislamiento.md](11_concurrencia_aislamiento.md) | Concurrencia demostrada con dos conexiones simultaneas sobre un laboratorio InnoDB independiente: prevencion de lectura sucia (REPEATABLE READ), lectura sucia visible (READ UNCOMMITTED), lectura no repetible posible (READ COMMITTED) y prevenida (snapshot), y bloqueo de fila con espera real de 6.91 s resuelta por COMMIT; cronologia verificada con NOW(6), sin SET GLOBAL, sin tablas reales tocadas y limpieza completa. Scripts: database/consultas/QUERY_05_concurrencia/ (11 archivos). |
| [12_subconsultas_exists.md](12_subconsultas_exists.md) | EXISTS y NOT EXISTS como operadores de subconsulta correlacionada sobre tablas reales de Kiro, con comparacion didactica IN vs EXISTS (resultados identicos) y combinacion EXISTS + NOT EXISTS en una misma consulta; exclusivamente SELECT, sin modificar datos ni estructura, con guardas de integridad identicas al final. Script reproducible: database/consultas/QUERY_06_subconsultas_exists.sql. |

> **Evidencia prevista (no elaborada aun):** la evidencia **13** archivara la construccion y validacion de las tablas `CONVERSACION` y `MENSAJE` (evolucion del chat posterior a la entrega academica): verificacion de estructura, FKs, indice de orden y permisos de escritura de `kiro_app`. Corresponde a la etapa documentada en la seccion 18 del README y en el apendice 15 del plan tecnico; todavia no existe porque la implementacion esta pendiente de autorizacion y ejecucion. Los mensajes de prueba del chat **no se insertaran manualmente con SQL**: se enviaran desde la interfaz y el backend los guardara automaticamente. Las evidencias 01 a 12 corresponden a la entrega academica y permanecen intactas.

## Proteccion de datos

- No se incluyen contrasenas, hashes ni credenciales: la unica salida que los contiene (SHOW GRANTS del usuario) fue expurgada antes de escribirse.
- No se incluyen datos de filas individuales: solo conteos y metadatos de estructura.
- El archivo de configuracion local de la aplicacion no forma parte de este paquete; se documenta que esta excluido del repositorio mediante .gitignore.

## Relacion con la documentacion

- Los conteos y el catalogo coinciden con lo declarado en README.md (12 tablas, 13 objetos, 14 FK, 19 indices secundarios).
- Los scripts reproducibles de los objetos viven en database/objetos/ y deben ejecutarse con cuenta administradora por el DEFINER.
