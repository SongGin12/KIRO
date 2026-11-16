-- =====================================================================
-- KIRO - Triggers (2)
-- Exportado de MariaDB 10.4.32 (base Kiro) el 2026-11-15 22:46.
-- Las definiciones son las reales del servidor; se conserva el DEFINER.
-- Los DROP estan incluidos para permitir re-ejecucion: ejecutar este
-- archivo solo con un usuario administrador (los objetos usan DEFINER).
-- =====================================================================

USE Kiro;


-- -------------------------------------------------------------------
-- trg_validar_actividad: BEFORE INSERT sobre ACTIVIDAD: valida titulo, descripcion y fecha limite obligatorios.
-- -------------------------------------------------------------------
DELIMITER $$

DROP TRIGGER IF EXISTS trg_validar_actividad $$

CREATE DEFINER=`root`@`localhost` TRIGGER trg_validar_actividad
BEFORE INSERT ON actividad
FOR EACH ROW
BEGIN
    IF NEW.titulo IS NULL OR TRIM(NEW.titulo) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El titulo de la actividad es obligatorio';
    END IF;

    IF NEW.descripcion IS NULL OR TRIM(NEW.descripcion) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La descripcion de la actividad es obligatoria';
    END IF;

    IF NEW.fecha_limite IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha limite es obligatoria';
    END IF;
END $$

DELIMITER ;

-- -------------------------------------------------------------------
-- trg_auditoria_actividad: AFTER UPDATE sobre ACTIVIDAD: registra el cambio en HISTORIAL_ACCION.
-- -------------------------------------------------------------------
DELIMITER $$

DROP TRIGGER IF EXISTS trg_auditoria_actividad $$

CREATE DEFINER=`root`@`localhost` TRIGGER trg_auditoria_actividad
AFTER UPDATE ON actividad
FOR EACH ROW
BEGIN
    INSERT INTO historial_accion (
        tipo_accion,
        entidad_afectada,
        id_registro_afectado,
        descripcion,
        fecha_accion,
        actor,
        resultado,
        id_usuario
    )
    VALUES (
        'ACTUALIZACION',
        'ACTIVIDAD',
        NEW.id_actividad,
        CONCAT(
            'Actividad: ', OLD.titulo,
            ' | Estado anterior: ', OLD.estado,
            ' | Estado nuevo: ', NEW.estado
        ),
        NOW(),
        'KIRO',
        'EXITOSO',
        NEW.id_usuario
    );
END $$

DELIMITER ;
