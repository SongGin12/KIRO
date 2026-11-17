-- =============================================================================
-- KIRO - QUERY_05 - 00: CONSTRUCCION DEL LABORATORIO DE CONCURRENCIA
-- =============================================================================
-- Proyecto:  KIRO (Bases de Datos II)
-- Servidor:  MariaDB 10.4.32
-- Ejecucion: mysql.exe -u root --default-character-set=utf8mb4 < 00_construccion_laboratorio.sql
--
-- OBJETIVO: crear una base de laboratorio INDEPENDIENTE (kiro_labo_concurrencia)
-- con una tabla InnoDB compartida, para que DOS SESIONES simultaneas operen
-- sobre el mismo recurso. Ninguna tabla real de Kiro es escrita.
--
-- GUARDIA PREVIA (fuera del script, obligatoria): la base NO debe existir.
-- Este script usa CREATE DATABASE sin IF NOT EXISTS: si la base ya existiera,
-- el script falla y no toca nada. Nunca se reutiliza una base preexistente.
--
-- Estructura: la tabla asiento simula un recurso unico reservable (analogia
-- con la reserva de citas de RN-07): una sola fila que dos sesiones leen,
-- actualizan y bloquean de forma concurrente.
-- =============================================================================

CREATE DATABASE kiro_labo_concurrencia
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE kiro_labo_concurrencia;

CREATE TABLE asiento (
    id       INT         NOT NULL,
    valor    INT         NOT NULL,
    etiqueta VARCHAR(60) NOT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB;

INSERT INTO asiento VALUES (1, 10, 'semilla');

-- Verificacion de construccion (solo lectura)
SELECT NOW(6) AS t_construccion, valor, etiqueta FROM asiento WHERE id = 1;
SELECT ENGINE FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'kiro_labo_concurrencia' AND TABLE_NAME = 'asiento';

SELECT 'FIN_00' AS fin;
