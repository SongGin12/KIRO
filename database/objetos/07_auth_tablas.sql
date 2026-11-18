-- =====================================================================
-- KIRO - Extension de identidad: tablas de soporte de autenticacion
-- MariaDB 10.4.32 · script 07 (1 de 5)
--
-- QUE HACE
--   Crea 3 tablas NUEVAS de soporte. NO altera ninguna de las 12 tablas
--   academicas del modelo BDD2.
--
--   ADMINISTRADOR       identidad administrativa separada (sin datos
--                       privados de los usuarios).
--   ACCION_ADMIN        auditoria del panel administrativo.
--   CODIGO_ACTIVACION   codigos de un solo uso para activar la
--                       contrasena de una cuenta existente. Solo se
--                       guarda el SHA-256, nunca el codigo.
--
-- REQUISITOS
--   Ejecutar como cuenta administradora sobre la base Kiro.
--   Despues ejecutar 08_auth_cuentas.sql.
--
-- SEGURIDAD
--   Este archivo no contiene contrasenas ni datos personales.
-- =====================================================================

USE `Kiro`;

-- ---------------------------------------------------------------------
-- 1. Administrador independiente.
--    Sin FK hacia USUARIO: el admin no puede navegar datos privados.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `administrador` (
    `id_admin`              INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `nombre`                VARCHAR(100) NOT NULL,
    `correo`                VARCHAR(150) NOT NULL,
    `hash_contrasena_admin` VARCHAR(255) NOT NULL,
    `activo`                TINYINT(1)   NOT NULL DEFAULT 1,
    `fecha_alta`            DATETIME     NOT NULL,
    `ultimo_acceso`         DATETIME     NULL DEFAULT NULL,
    PRIMARY KEY (`id_admin`),
    UNIQUE KEY `uq_administrador_correo` (`correo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 2. Auditoria administrativa (append-only para la cuenta tecnica).
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `accion_admin` (
    `id_accion_admin` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `id_admin`        INT UNSIGNED    NOT NULL,
    `fecha`           DATETIME(6)     NOT NULL,
    `tipo_accion`     VARCHAR(30)     NOT NULL,
    `entidad`         VARCHAR(30)     NULL DEFAULT NULL,
    `id_objetivo`     INT(11)         NULL DEFAULT NULL,
    `resultado`       VARCHAR(20)     NOT NULL,
    `detalle`         VARCHAR(255)    NULL DEFAULT NULL,
    PRIMARY KEY (`id_accion_admin`),
    KEY `ix_accion_admin_fecha` (`id_admin`, `fecha`),
    CONSTRAINT `fk_accion_admin_admin`
        FOREIGN KEY (`id_admin`) REFERENCES `administrador` (`id_admin`)
        ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 3. Codigos de activacion (un solo uso, con caducidad y bloqueo).
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `codigo_activacion` (
    `id_codigo`       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `id_usuario`      INT(11)         NOT NULL,
    `id_admin_emisor` INT UNSIGNED    NOT NULL,
    `hash_codigo`     CHAR(64)        NOT NULL,
    `emitido_en`      DATETIME(6)     NOT NULL,
    `expira_en`       DATETIME(6)     NOT NULL,
    `usado_en`        DATETIME(6)     NULL DEFAULT NULL,
    `anulado_en`      DATETIME(6)     NULL DEFAULT NULL,
    `bloqueado_en`    DATETIME(6)     NULL DEFAULT NULL,
    `intentos`        TINYINT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`id_codigo`),
    UNIQUE KEY `uq_codigo_hash` (`hash_codigo`),
    KEY `ix_codigo_usuario_estado` (`id_usuario`, `usado_en`, `anulado_en`, `expira_en`),
    CONSTRAINT `fk_codigo_usuario`
        FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT `fk_codigo_admin`
        FOREIGN KEY (`id_admin_emisor`) REFERENCES `administrador` (`id_admin`)
        ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
