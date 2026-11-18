-- =====================================================================
-- KIRO (evolucion chat) - Tablas CONVERSACION y MENSAJE
-- Preparado para MariaDB 10.4.32. ETAPA 2 - script 2 de 4.
--
-- OBJETIVO
--   Crear las 2 entidades nuevas del DER de 14 entidades: el chat real
--   del companero. El resto del esquema (12 tablas academicas) NO se
--   toca; el script canonico database/KIRO_MariaDB.sql permanece
--   intacto como registro de la entrega de Bases de Datos II.
--
-- ADVERTENCIA
--   Ejecutar SOLO con cuenta administradora, y DESPUES de
--   database/chat/01_indice_sesion.sql (la FK compuesta de
--   CONVERSACION referencia el indice unico de INICIO_SESION).
--
-- REQUISITOS DEL DISENO APROBADO
--   1. Motor InnoDB y charset/collation explicitos: el collation por
--      defecto del servidor es utf8mb4_general_ci, distinto del
--      utf8mb4_unicode_ci del resto del modelo; se declara siempre.
--   2. Sin atributos derivados (3FN): la actividad reciente de una
--      conversacion se obtiene con MAX(fecha_envio) apoyado en el
--      indice de orden, no con una columna redundante.
--   3. Orden total estable: ix_mensaje_orden incluye id_mensaje para
--      desempatar mensajes del mismo segundo (DATETIME resuelve a 1s).
--   4. FK compuesta (id_sesion, id_usuario): garantiza que la sesion
--      de la conversacion pertenezca al mismo dueno. Con id_sesion
--      NULL no se evalua (MATCH SIMPLE).
--   5. Creacion perezosa (criterio de la aplicacion, no del DDL): el
--      backend inserta CONVERSACION en la misma transaccion que el
--      primer MENSAJE. Los mensajes de prueba NO se insertan con SQL
--      manual: se envian desde la interfaz y el backend los guarda.
--
-- DOMINIOS DE APLICACION (patron del modelo, estados como VARCHAR)
--   CONVERSACION.estado : 'Abierta' | 'Cerrada'
--   MENSAJE.remitente   : 'USUARIO' | 'KIRO' | 'SISTEMA'
--   Ambos se asignan y validan SIEMPRE en el servidor (PHP); el
--   cliente nunca envia estos valores.
-- =====================================================================

USE `Kiro`;

-- ---------------------------------------------------------------------
-- 1. CONVERSACION: unidad de chat con principio y fin.
-- ---------------------------------------------------------------------
CREATE TABLE `CONVERSACION` (
  `id_conversacion` INT NOT NULL AUTO_INCREMENT,
  `id_usuario`      INT NOT NULL,
  `titulo`          VARCHAR(150) NOT NULL,
  `fecha_inicio`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado`          VARCHAR(20) NOT NULL,
  `id_sesion`       INT NULL,
  PRIMARY KEY (`id_conversacion`),
  KEY `ix_conversacion_usuario` (`id_usuario`),
  CONSTRAINT `fk_conversacion_usuario` FOREIGN KEY (`id_usuario`)
    REFERENCES `USUARIO` (`id_usuario`)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_conversacion_sesion` FOREIGN KEY (`id_sesion`, `id_usuario`)
    REFERENCES `INICIO_SESION` (`id_sesion`, `id_usuario`)
    ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 2. MENSAJE: cada mensaje enviado dentro de una conversacion.
--    contenido TEXT admite 65.535 bytes (peor caso del limite de
--    2000 puntos de codigo Unicode: ~8.000 bytes), con margen sobrado.
--    El limite se aplica en PHP (mb_strlen, UTF-8), no aqui: el
--    servidor no esta en modo estricto y la columna no es la barrera.
-- ---------------------------------------------------------------------
CREATE TABLE `MENSAJE` (
  `id_mensaje`      INT NOT NULL AUTO_INCREMENT,
  `id_conversacion` INT NOT NULL,
  `remitente`       VARCHAR(20) NOT NULL,
  `contenido`       TEXT NOT NULL,
  `fecha_envio`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_mensaje`),
  KEY `ix_mensaje_orden` (`id_conversacion`, `fecha_envio`, `id_mensaje`),
  CONSTRAINT `fk_mensaje_conversacion` FOREIGN KEY (`id_conversacion`)
    REFERENCES `CONVERSACION` (`id_conversacion`)
    ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Notas de diseno:
--   - Los indices de las FK simples (ix_conversacion_usuario y el
--     implicito de fk_mensaje_conversacion) se declaran/usan para que
--     InnoDB no cree indices automaticos con nombres de sistema.
--   - Sin DELETE (RESTRICT) y sin eliminacion fisica: las
--     conversaciones se cierran (estado='Cerrada'), coherente con la
--     eliminacion logica pendiente RN-09 del plan academico.
--   - Compatibilidad futura: HISTORIAL_ACCION.entidad_afectada podra
--     almacenar 'CONVERSACION'/'MENSAJE' sin cambios de esquema.
-- ---------------------------------------------------------------------
