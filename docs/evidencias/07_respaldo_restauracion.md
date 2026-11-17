# Evidencia 07 - Respaldo y restauracion de la base de datos KIRO

- Servidor: MariaDB 10.4.32-MariaDB, base `Kiro`
- Fecha de la prueba: 2026-11-16
- Metodo: respaldo logico con `mysqldump` y restauracion en una base de prueba independiente (`kiro_restore_test_3`). La base original `Kiro` no recibio ninguna escritura durante todo el proceso; se verifico con conteos y `CHECKSUM TABLE` antes y despues.
- Resultado: la tercera restauracion fue completa y verificada (12/12 tablas identicas en contenido). Los dos primeros intentos fallaron por problemas de codificacion de caracteres y quedan documentados con su diagnostico, porque la causa raiz es una leccion academica central de esta evidencia.

---

## 1. Objetivo de la prueba

Comprobar que la base de datos KIRO puede:

1. **Respaldarse** completamente: estructura (tablas, claves, indices), datos, vistas, funciones, procedimientos y triggers, con un comando reproducible y justificado.
2. **Restaurarse** en una base independiente sin alterar la original.
3. **Verificarse** a nivel de estructura, contenido byte a byte y objetos SQL, con metodos que no dependan de la apariencia en pantalla.

## 2. Herramientas y versiones utilizadas

| Herramienta | Version | Uso |
|---|---|---|
| `mysqldump.exe` | 10.19 Distrib 10.4.32-MariaDB (XAMPP) | Respaldo logico completo |
| `mysql.exe` | 15.1 Distrib 10.4.32-MariaDB | Restauracion (redireccion `<`) y verificaciones |
| Windows PowerShell 5.1 + `cmd.exe` | Sistema anfitrion | Ejecucion de los comandos (con sus diferencias documentadas) |
| `CHECKSUM TABLE`, `information_schema`, `CRC32()` | Servidor MariaDB | Verificaciones de integridad |

Cuenta usada: administradora local (`root`), necesaria porque los objetos conservan el `DEFINER=root@localhost`. No se solicitaron ni mostraron contrasenas.

## 3. Generacion del respaldo

### 3.1. Comando final correcto (tercer intento)

```bat
mysqldump.exe -u root --single-transaction --routines --triggers --events --add-drop-table --default-character-set=utf8mb4 Kiro > kiro_respaldo_20261116_utf8.sql
```

ejecutado con redireccion directa de `cmd.exe` (mysqldump escribe los bytes al archivo, sin pasar por la decodificacion de texto de PowerShell).

**Justificacion de cada opcion:**

| Opcion | Por que |
|---|---|
| `--single-transaction` | Copia consistente de las tablas InnoDB sin bloquear el servidor |
| `--routines` | Incluye las 5 funciones y los 2 SP; sin ella no se respaldarian |
| `--triggers` | Incluye los 2 triggers (va por defecto; se declara explicito) |
| `--events` | Completa el respaldo logico aunque KIRO no tenga eventos |
| `--add-drop-table` | Permite re-ejecutar la restauracion (`DROP TABLE IF EXISTS` en el dump) |
| `--default-character-set=utf8mb4` | Fidelidad del charset (utf8mb4_unicode_ci) |
| SIN `--databases` | Evita que el dump contenga `CREATE DATABASE Kiro`/`USE Kiro`, que podria dirigir una restauracion accidental a la base original |
| SIN `--add-drop-database` | Evita emitir `DROP DATABASE Kiro` |
| SIN `--force` | La restauracion debe detenerse ante el primer error |

### 3.2. Contenido del respaldo (verificado por conteo en el archivo)

- 12 `CREATE TABLE`, 12 bloques `INSERT` semilla (120 registros), 14 FK y 19 indices (dentro del DDL).
- 4 vistas, 5 funciones, 2 SP, 2 triggers (los triggers en formato condicional `/*!50003 ...*/`).
- Sin `CREATE DATABASE` ni `USE` (proposito: restauracion controlada del destino).
- Tamano: 48.087 bytes; el primer dump (corrupto): 48.489 bytes.
- Sin credenciales ni contrasenas: los datos semilla son ficticios y los "hashes" son marcadores `hash_prueba_###`.

## 4. Primer intento: corrupcion por pipe de PowerShell

**Procedimiento usado (incorrecto):**

```powershell
Get-Content respaldo.sql -Raw | mysql.exe -u root kiro_restore_test
```

**Resultado:** la restauracion creo las 12 tablas con 122 registros y todos los objetos, PERO los caracteres acentuados quedaron como signos `?` (por ejemplo `Reuni??n acad??mica`) en 9 de las 12 tablas.

**Causa raiz:** Windows PowerShell 5.1 transmite texto a programas externos con `$OutputEncoding` en ASCII por defecto. Cada caracter no-ASCII del contenido UTF-8 se convirtio en `?` en el transito del pipe. El archivo de respaldo era correcto; la corrupcion ocurrio solo al transportar su contenido como texto por PowerShell.

**Leccion:** el pipe de texto de la consola no es un transporte seguro de bytes.

## 5. Segundo intento: transporte correcto de un archivo que ya estaba corrupto

**Procedimiento usado:** redireccion directa con `cmd.exe` (`mysql.exe ... < respaldo.sql`), que transporta los bytes del archivo sin conversion.

**Resultado:** la estructura y los conteos quedaron perfectos, pero el texto acentuado quedo con caracteres de dibujo de caja (`Reuni├│n acad├®mica`).

**Causa raiz (diagnostico por bytes):** el problema no era el transporte sino el ARCHIVO de respaldo. El primer dump se habia generado con `mysqldump | Set-Content`: PowerShell decodifico la salida UTF-8 de mysqldump usando la pagina de codigos OEM de la consola (CP850) y la re-codifico a UTF-8. Verificacion binaria del archivo:

- El archivo NO contiene ningun `C3 B3` (bytes UTF-8 reales de la "o").
- Contiene `E2 94 9C E2 94 82` (secuencia UTF-8 de los caracteres de dibujo de caja), que es exactamente la reinterpretacion CP850 de los bytes `C3 B3`.
- La base restaurada guardo byte a byte esos mismos caracteres: `HEX(titulo)` = `5265756E69 E2949C E29482 6E ...`.

**Leccion:** un verificacion por texto en consola puede ser enganosa: al imprimir el archivo corrupto, la consola re-codifico los bytes y el texto SE MOSTRO como correcto (`Reunion` aparente) aunque no lo era. La verificacion confiable se hace a nivel de bytes y contra la base, no en pantalla.

## 6. Tercer intento: generacion binaria correcta y restauracion verificada

### 6.1. Generacion sin conversiones de texto

`mysqldump ... > archivo` ejecutado por `cmd.exe`: redireccion de bytes directa, sin `Get-Content`, `Set-Content`, `Out-File` ni pipes de PowerShell.

### 6.2. Verificacion binaria previa del archivo (antes de restaurar)

| Comprobacion | Valor esperado | Resultado |
|---|---|---|
| Existencia y tamano | > 0 bytes | 48.087 bytes |
| Bytes `C3 B3` (o real) presentes | >= 1 ocurrencia | indice 2250 |
| Bytes `C3 A9` (e real) presentes | >= 1 | indice 7243 |
| Bytes `C3 B1` (n real) presentes | >= 1 | indice 2651 |
| Bytes de mojibake `E2 94 9C` / `E2 94 82` | 0 ocurrencias | indice -1 (ausentes) |
| Bytes tras el literal `Reuni` | `52 65 75 6E 69 C3 B3 6E 20 ...` | coinciden |
| Comparacion con `HEX(titulo)` de la base original | `5265756E69C3B36E2061636164C3A96D696361` | el fragmento del archivo es identico |

El archivo supero la verificacion: representa exactamente los mismos bytes que la base original.

### 6.3. Restauracion

1. Guardia previa: `kiro_restore_test_3` no existia (comprobado en `information_schema.SCHEMATA`).
2. Creacion: `CREATE DATABASE kiro_restore_test_3 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`
3. Restauracion por redireccion directa: `mysql.exe -u root --default-character-set=utf8mb4 kiro_restore_test_3 < respaldo.sql` (exit 0, sin errores).

## 7. Codificacion, bytes y transporte: la diferencia que explica los tres intentos

| Concepto | Que es | Donde fallo |
|---|---|---|
| **Codificacion de caracteres** | El mapa entre caracteres (o, e, n) y numeros de bytes (UTF-8: `C3 B3`) | La generacion del primer dump: PowerShell leyo los bytes UTF-8 como si fueran CP850 |
| **Bytes del archivo** | La secuencia fisica que contiene el respaldo | El primer archivo nacio con mojibake; el segundo archivo nacio correcto |
| **Transporte de datos** | El camino por el que esos bytes llegan al servidor | El primer intento corrompio el transporte (pipe ASCII); el segundo y el tercer transporte fueron fieles |

Resumen de los tres intentos:

| Intento | Archivo | Transporte | Resultado |
|---|---|---|---|
| 1 | Correcto | Corrupto (pipe ASCII) | Texto con `?` |
| 2 | Corrupto (mojibake CP850) | Correcto (cmd) | Texto con caracteres de caja |
| 3 | Correcto (cmd, bytes directos) | Correcto (cmd) | **Identico a la original** |

## 8. Comparacion de estructura y contenido (restauracion verificada)

### 8.1. Estructura de `kiro_restore_test_3`

| Elemento | Esperado | Observado |
|---|---|---|
| Tablas | 12 | 12 |
| Claves primarias | 12 | 12 |
| Claves foraneas | 14 | 14 |
| Indices secundarios | 19 | 19 |
| Vistas | 4 | 4 |
| Funciones | 5 | 5 |
| Procedimientos | 2 | 2 |
| Triggers | 2 | 2 |
| Registros totales | 122 | 122 |

### 8.2. Fingerprints de contenido por tabla (12/12 identicos)

Metodo: por cada tabla, un fingerprint calculado dentro del servidor con `SUM(CRC32(CONCAT_WS('|', todas_las_columnas)))` (los campos de texto con `REPLACE` de `|` y `IFNULL`), comparando `Kiro` contra `kiro_restore_test_3`. Diferencia de filas y de fingerprint: **0 en las 12 tablas**.

| Tabla | diff_filas | diff_contenido |
|---|---|---|
| USUARIO | 0 | 0 |
| REGISTRO_USUARIO | 0 | 0 |
| PERFIL_KIRO | 0 | 0 |
| INICIO_SESION | 0 | 0 |
| CATEGORIA | 0 | 0 |
| PROYECTO | 0 | 0 |
| NOTA | 0 | 0 |
| RECURSO | 0 | 0 |
| ACTIVIDAD | 0 | 0 |
| CITA | 0 | 0 |
| RECUERDO | 0 | 0 |
| HISTORIAL_ACCION | 0 | 0 |

Este metodo supera a `CHECKSUM TABLE` como comparador entre dos bases, porque el checksum fisico depende de la representacion interna de cada tabla y puede diferir aunque el contenido logico sea identico (se observo ese efecto entre `Kiro` y la copia restaurada).

## 9. Verificacion de acentos y caracteres especiales

Comparacion binaria directa del mismo registro en ambas bases:

```sql
SELECT HEX(titulo) FROM Kiro.cita WHERE id_cita = 1;
SELECT HEX(titulo) FROM kiro_restore_test_3.cita WHERE id_cita = 1;
```

- Original: `5265756E69C3B36E2061636164C3A96D696361` ("Reunion academica" con o y e reales en UTF-8).
- Restaurada: **identica**.
- Escaneo de columnas de texto de CITA en la restaurada buscando `?` y caracteres de caja: 0 coincidencias.

## 10. Verificacion de vistas, funciones, procedimientos y triggers

### 10.1. Vistas (4): existencia, definicion y referencias

Las cuatro vistas existen en la copia. Punto critico verificado: a quien apuntan sus definiciones internas.

```sql
SELECT TABLE_NAME, VIEW_DEFINITION FROM information_schema.VIEWS
WHERE TABLE_SCHEMA = 'kiro_restore_test_3';
```

Resultado observado: las 4 vistas referencian `kiro_restore_test_3`, no la base original. MariaDB reescribio las referencias calificadas al momento de crearlas en el nuevo esquema, de modo que la copia es autosuficiente (mejor de lo previsto, dado que las definiciones exportadas en `database/objetos/01_vistas.sql` llevan el nombre `kiro` calificado).

Conteos de las vistas restauradas: `vw_kiro_proximas_citas` 5, `vw_kiro_actividades_pendientes` 4, `vw_kiro_proyectos_activos` 8, `vw_kiro_notas_categorias` 10 (coinciden con los de la original para la misma fecha).

### 10.2. Funciones (5): prueba de lectura

Llamadas ejecutadas sobre el esquema restaurado con id de prueba 1, retornos identicos a los de la original: `fn_total_actividades_pendientes` = 0, `fn_total_proyectos_activos` = 1, `fn_total_notas_usuario` = 1, `fn_total_recursos_usuario` = 1, `fn_calcular_fecha_fin_cita(1)` = `2026-11-12 10:00:00`.

### 10.3. Procedimientos (2)

- `sp_resumir_actividades_usuario` (solo lectura, cursor): `CALL kiro_restore_test_3.sp_resumir_actividades_usuario(1);` ejecutado con exito y resultado identico a la original (0 completadas, 1 en progreso, 0 pendientes, 1 vencida, total 1).
- `sp_registrar_cita_segura` (transaccional): NO se ejecuto, porque modifica datos; su verificacion se limita a la existencia del objeto en la copia.

### 10.4. Triggers (2)

`trg_validar_actividad` y `trg_auditoria_actividad` existen en la copia (catalogo `information_schema.TRIGGERS`). No se dispararon durante la prueba: dispararlos requeriria INSERT o UPDATE sobre la copia, fuera del alcance de solo lectura de esta evidencia.

## 11. La base original antes y despues: sin cambios

`CHECKSUM TABLE` de las 12 tablas de `Kiro`, medido antes de cualquier respaldo y repetido al final del proceso; los 12 valores coinciden. Tambien coinciden los conteos (122) y el inventario de objetos (4 vistas, 5 funciones, 2 SP, 2 triggers). La base original no recibio ninguna escritura: la restauracion se dirigio exclusivamente a la base de prueba y el dump no contiene `USE Kiro`.

Valores de checksum registrados (iguales en ambas mediciones): USUARIO 882274266, REGISTRO_USUARIO 3702753872, PERFIL_KIRO 2789492068, INICIO_SESION 3551093410, CATEGORIA 1926394981, PROYECTO 1581122082, NOTA 1901855308, RECURSO 2631569251, ACTIVIDAD 2584779342, CITA 1030271630, RECUERDO 4189147891, HISTORIAL_ACCION 225788971.

## 12. Estado final de las bases y los respaldos

| Objeto | Estado |
|---|---|
| `Kiro` (original) | Intacta y verificada (checksums pre/post identicos) |
| `kiro_restore_test` | Conservada como registro del intento 1 (texto con `?`); NO es una copia valida |
| `kiro_restore_test_2` | Conservada como registro del intento 2 (mojibake de caja); NO es una copia valida |
| `kiro_restore_test_3` | **Copia valida y verificada** (12/12 tablas identicas en contenido) |
| `kiro_respaldo_20261116.sql` | Primer dump, corrupto en acentos; conservado como material del diagnostico |
| `kiro_respaldo_20261116_utf8.sql` | **Dump correcto**, generado y verificado a nivel de bytes |

Ambos respaldos viven fuera del repositorio, en la carpeta personal `Respaldo_KIRO`; ninguno se publica en GitHub.

## 13. Conclusiones y limitaciones

**Conclusiones demostradas:**

1. La base KIRO se respalda completamente (estructura, datos, claves, indices, vistas, rutinas y triggers) con `mysqldump` y se restaura en una base independiente con exito verificado a nivel de bytes.
2. La integridad del respaldo no depende solo del comando correcto: la codificacion del entorno de ejecucion puede corromper los datos sin que el comando falle (exit 0 en los tres intentos).
3. La verificacion confiable es la que compara bytes y contenido dentro del servidor (`HEX`, fingerprints con `CRC32`), no la inspeccion visual en consola.
4. La base original permanece intacta durante respaldo y restauracion, comprobado con `CHECKSUM TABLE` antes y despues.

**Limitaciones:**

1. El entorno es Windows con pagina de codigos OEM no-UTF-8; en un entorno Linux o con consola UTF-8 los riesgos de codificacion aqui documentados no se presentan de la misma forma, pero la practica de verificacion binaria sigue siendo la recomendada.
2. El trigger de auditoria no se disparo en la copia (requiere escritura); su comportamiento ya esta demostrado sobre la base original (evidencia 01, registro de laboratorio) y la existencia del objeto en la copia si esta verificada.
3. Los conteos de `vw_kiro_proximas_citas` dependen de la fecha de ejecucion (`CURRENT_TIMESTAMP`); los valores documentados corresponden al dia de la prueba.
4. La restauracion requiere cuenta administradora por el `DEFINER` de los objetos; con el usuario de aplicacion `kiro_app` no seria posible.
5. Las bases de prueba y el dump corrupto se conservan como registro del proceso academico; en un entorno productivo se eliminarian tras verificar la restauracion.
