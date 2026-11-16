-- =====================================================================
-- KIRO - Funciones almacenadas (5)
-- Exportado de MariaDB 10.4.32 (base Kiro) el 2026-11-15 22:46.
-- Las definiciones son las reales del servidor; se conserva el DEFINER.
-- Los DROP estan incluidos para permitir re-ejecucion: ejecutar este
-- archivo solo con un usuario administrador (los objetos usan DEFINER).
-- =====================================================================

USE Kiro;


-- -------------------------------------------------------------------
-- fn_total_actividades_pendientes: Total de actividades pendientes o en progreso de un usuario.
-- -------------------------------------------------------------------
DELIMITER $$

DROP FUNCTION IF EXISTS fn_total_actividades_pendientes $$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_total_actividades_pendientes`(p_id_usuario INT
) RETURNS int(11)
    READS SQL DATA
BEGIN
    DECLARE v_total INT;

    SELECT COUNT(*)
    INTO v_total
    FROM actividad
    WHERE id_usuario = p_id_usuario
      AND estado = 'Pendiente';

    RETURN v_total;
END $$

DELIMITER ;

-- -------------------------------------------------------------------
-- fn_total_proyectos_activos: Total de proyectos en progreso de un usuario.
-- -------------------------------------------------------------------
DELIMITER $$

DROP FUNCTION IF EXISTS fn_total_proyectos_activos $$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_total_proyectos_activos`(p_id_usuario INT
) RETURNS int(11)
    READS SQL DATA
BEGIN
    DECLARE v_total INT;

    SELECT COUNT(*)
    INTO v_total
    FROM proyecto
    WHERE id_usuario = p_id_usuario
      AND estado <> 'Completado';

    RETURN v_total;
END $$

DELIMITER ;

-- -------------------------------------------------------------------
-- fn_calcular_fecha_fin_cita: Fecha y hora de fin de una cita a partir de su inicio y su duracion.
-- -------------------------------------------------------------------
DELIMITER $$

DROP FUNCTION IF EXISTS fn_calcular_fecha_fin_cita $$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_calcular_fecha_fin_cita`(p_id_cita INT
) RETURNS datetime
    READS SQL DATA
BEGIN
    DECLARE v_fecha_fin DATETIME;

    SELECT DATE_ADD(
        fecha_inicio,
        INTERVAL duracion_minutos MINUTE
    )
    INTO v_fecha_fin
    FROM cita
    WHERE id_cita = p_id_cita;

    RETURN v_fecha_fin;
END $$

DELIMITER ;

-- -------------------------------------------------------------------
-- fn_total_notas_usuario: Total de notas de un usuario.
-- -------------------------------------------------------------------
DELIMITER $$

DROP FUNCTION IF EXISTS fn_total_notas_usuario $$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_total_notas_usuario`(p_id_usuario INT
) RETURNS int(11)
    READS SQL DATA
BEGIN
    DECLARE v_total INT;

    SELECT COUNT(*)
    INTO v_total
    FROM nota
    WHERE id_usuario = p_id_usuario;

    RETURN v_total;
END $$

DELIMITER ;

-- -------------------------------------------------------------------
-- fn_total_recursos_usuario: Total de recursos de un usuario.
-- -------------------------------------------------------------------
DELIMITER $$

DROP FUNCTION IF EXISTS fn_total_recursos_usuario $$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_total_recursos_usuario`(p_id_usuario INT
) RETURNS int(11)
    READS SQL DATA
BEGIN
    DECLARE v_total INT;

    SELECT COUNT(*)
    INTO v_total
    FROM recurso
    WHERE id_usuario = p_id_usuario;

    RETURN v_total;
END $$

DELIMITER ;
