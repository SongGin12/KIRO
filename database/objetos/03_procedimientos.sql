-- =====================================================================
-- KIRO - Procedimientos almacenados (2)
-- Exportado de MariaDB 10.4.32 (base Kiro) el 2026-11-15 22:46.
-- Las definiciones son las reales del servidor; se conserva el DEFINER.
-- Los DROP estan incluidos para permitir re-ejecucion: ejecutar este
-- archivo solo con un usuario administrador (los objetos usan DEFINER).
-- =====================================================================

USE Kiro;


-- -------------------------------------------------------------------
-- sp_registrar_cita_segura: Alta segura de cita: valida datos obligatorios, comprueba solapamientos y usa transaccion con COMMIT y ROLLBACK.
-- -------------------------------------------------------------------
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_registrar_cita_segura $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrar_cita_segura`(
    IN p_titulo VARCHAR(150),
    IN p_descripcion TEXT,
    IN p_fecha_inicio DATETIME,
    IN p_duracion_minutos INT,
    IN p_lugar VARCHAR(200),
    IN p_id_usuario INT
)
BEGIN
    DECLARE v_usuario INT DEFAULT 0;
    DECLARE v_conflictos INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF p_titulo IS NULL OR TRIM(p_titulo) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El titulo de la cita es obligatorio';
    END IF;

    IF p_fecha_inicio IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha de inicio es obligatoria';
    END IF;

    IF p_duracion_minutos IS NULL OR p_duracion_minutos <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La duracion debe ser mayor que cero';
    END IF;

    SELECT COUNT(*)
    INTO v_usuario
    FROM usuario
    WHERE id_usuario = p_id_usuario;

    IF v_usuario = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario no existe';
    END IF;

    SELECT COUNT(*)
    INTO v_conflictos
    FROM cita
    WHERE id_usuario = p_id_usuario
      AND estado <> 'Cancelada'
      AND p_fecha_inicio < DATE_ADD(
          fecha_inicio,
          INTERVAL duracion_minutos MINUTE
      )
      AND DATE_ADD(
          p_fecha_inicio,
          INTERVAL p_duracion_minutos MINUTE
      ) > fecha_inicio;

    IF v_conflictos > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario ya tiene una cita en ese horario';
    END IF;

    INSERT INTO cita (
        titulo,
        descripcion,
        fecha_inicio,
        duracion_minutos,
        lugar,
        estado,
        id_usuario
    )
    VALUES (
        p_titulo,
        COALESCE(p_descripcion, ''),
        p_fecha_inicio,
        p_duracion_minutos,
        COALESCE(p_lugar, 'Por definir'),
        'Pendiente',
        p_id_usuario
    );

    COMMIT;

    SELECT
        'Cita registrada correctamente' AS mensaje,
        LAST_INSERT_ID() AS id_cita;
END $$

DELIMITER ;

-- -------------------------------------------------------------------
-- sp_resumir_actividades_usuario: Recorre con un cursor las actividades de un usuario y las resume por estado.
-- -------------------------------------------------------------------
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_resumir_actividades_usuario $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_resumir_actividades_usuario`(
    IN p_id_usuario INT
)
BEGIN
    DECLARE v_fin INT DEFAULT 0;
    DECLARE v_estado VARCHAR(20);
    DECLARE v_fecha_limite DATE;

    DECLARE v_completadas INT DEFAULT 0;
    DECLARE v_progreso INT DEFAULT 0;
    DECLARE v_pendientes INT DEFAULT 0;
    DECLARE v_vencidas INT DEFAULT 0;

    DECLARE cur_actividades CURSOR FOR
        SELECT estado, fecha_limite
        FROM actividad
        WHERE id_usuario = p_id_usuario;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_fin = 1;

    OPEN cur_actividades;

    recorrer: LOOP
        FETCH cur_actividades
        INTO v_estado, v_fecha_limite;

        IF v_fin = 1 THEN
            LEAVE recorrer;
        END IF;

        IF v_estado = 'Completada' THEN
            SET v_completadas = v_completadas + 1;
        ELSEIF v_estado = 'En progreso' THEN
            SET v_progreso = v_progreso + 1;
        ELSEIF v_estado = 'Pendiente' THEN
            SET v_pendientes = v_pendientes + 1;
        END IF;

        IF v_fecha_limite < CURDATE()
           AND v_estado <> 'Completada' THEN
            SET v_vencidas = v_vencidas + 1;
        END IF;

    END LOOP;

    CLOSE cur_actividades;

    SELECT
        p_id_usuario AS id_usuario,
        v_completadas AS actividades_completadas,
        v_progreso AS actividades_en_progreso,
        v_pendientes AS actividades_pendientes,
        v_vencidas AS actividades_vencidas,
        (v_completadas + v_progreso + v_pendientes) AS total_actividades;
END $$

DELIMITER ;
