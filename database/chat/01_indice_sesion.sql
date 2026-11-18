-- =====================================================================
-- KIRO (evolucion chat) - Indice unico en INICIO_SESION
-- Preparado para MariaDB 10.4.32. ETAPA 2 - script 1 de 4.
--
-- OBJETIVO
--   Habilitar la FK compuesta de CONVERSACION hacia INICIO_SESION:
--     CONVERSACION(id_sesion, id_usuario) -> INICIO_SESION(id_sesion, id_usuario)
--   El indice unico garantiza que una conversacion solo pueda senalar
--   una sesion del MISMO usuario (InnoDB exige un indice unico sobre
--   las columnas referenciadas).
--
-- ADVERTENCIA
--   Ejecutar SOLO con cuenta administradora (por ejemplo root local).
--   Este es el unico script de la evolucion que toca una de las 12
--   tablas academicas, y lo hace de forma ADITIVA: no cambia datos,
--   columnas ni comportamientos existentes.
--
-- SEGURIDAD LOGICA
--   El indice es logicamente redundante con la PK (id_sesion ya es
--   unica), por lo que no puede fallar con los datos actuales: la
--   combinacion (id_sesion, id_usuario) es unica por definicion.
--
-- ORDEN
--   Debe ejecutarse ANTES de database/chat/02_tablas_chat.sql, porque
--   la FK compuesta de CONVERSACION referencia este indice.
--
-- NOTA
--   Este script NO es idempotente: si el indice ya existe, MariaDB
--   devuelve el error 1061 (duplicate key name) sin causar dano.
--   Comprobar antes con: SHOW INDEX FROM Kiro.INICIO_SESION;
-- =====================================================================

USE `Kiro`;

ALTER TABLE `INICIO_SESION`
  ADD UNIQUE KEY `uk_inicio_sesion_usuario` (`id_sesion`, `id_usuario`);

-- ---------------------------------------------------------------------
-- Verificacion rapida (solo lectura): el indice debe figurar como
-- NON_UNIQUE = 0, con id_sesion en seq 1 y id_usuario en seq 2.
-- SHOW INDEX FROM `Kiro`.`INICIO_SESION`;
-- ---------------------------------------------------------------------
