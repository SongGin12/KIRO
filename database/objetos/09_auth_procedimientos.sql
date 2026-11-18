-- =====================================================================
-- KIRO - Procedimientos de autenticacion controlada
-- MariaDB 10.4.32 · script 09 (3 de 5)
--
-- QUE HACE
--   sp_emitir_codigo_activacion : registra un codigo de un solo uso.
--   sp_activar_credencial       : activa la contrasena de una cuenta.
--
-- DECISIONES TECNICAS
--   * Ambos SP son SQL SECURITY DEFINER y su dueno es
--     kiro_sp_definer@127.0.0.1 (cuenta bloqueada para login).
--     Por eso el script PHP no necesita (ni tiene) privilegios sobre
--     USUARIO, CODIGO_ACTIVACION ni ACCION_ADMIN.
--   * El codigo en claro NUNCA llega a la base: PHP genera 32 bytes
--     aleatorios y envia solo su SHA-256.
--   * La lista blanca {1,2} vive dentro de los procedimientos: aunque
--     la herramienta tenga un fallo, la base rechaza otros ids.
--   * El CAS (comparar-y-cambiar) del hash anterior se hace aqui,
--     leyendo USUARIO con FOR UPDATE. El script no lee ese valor.
--   * El contador de intentos se confirma dentro de la transaccion
--     del SP. Si la activacion falla, el COMMIT conserva el intento:
--     no se pierde por un ROLLBACK externo.
--
-- REQUISITOS
--   Haber ejecutado 07_auth_tablas.sql y 08_auth_cuentas.sql.
-- =====================================================================

USE `Kiro`;

DROP PROCEDURE IF EXISTS `sp_emitir_codigo_activacion`;
DROP PROCEDURE IF EXISTS `sp_activar_credencial`;

DELIMITER $$

-- ---------------------------------------------------------------------
-- EMISION
--   Valida usuario permitido, admin activo y vigencia.
--   Anula codigos anteriores no usados del mismo usuario.
--   Guarda SOLO el SHA-256 del codigo y registra la emision.
--   Devuelve id_codigo y expira_en (nunca el codigo).
-- ---------------------------------------------------------------------
CREATE DEFINER='kiro_sp_definer'@'127.0.0.1' PROCEDURE `sp_emitir_codigo_activacion`(
    IN  p_id_usuario       INT,
    IN  p_id_admin         INT UNSIGNED,
    IN  p_hash_codigo      CHAR(64),
    IN  p_vigencia_minutos INT,
    OUT p_id_codigo        BIGINT UNSIGNED,
    OUT p_expira_en        DATETIME(6),
    OUT p_resultado        VARCHAR(40)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_usuario_existe INT DEFAULT 0;
    DECLARE v_admin_activo   INT DEFAULT 0;
    DECLARE v_ya_activada    INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_id_codigo = NULL;
        SET p_expira_en = NULL;
        SET p_resultado = 'ERROR_INTERNO';
    END;

    SET p_id_codigo = NULL;
    SET p_expira_en = NULL;
    SET p_resultado = 'ERROR_INTERNO';

    IF p_id_usuario NOT IN (1, 2) THEN
        SET p_resultado = 'ID_NO_AUTORIZADO';
    ELSEIF p_hash_codigo IS NULL OR CHAR_LENGTH(p_hash_codigo) <> 64 THEN
        SET p_resultado = 'HASH_INVALIDO';
    ELSEIF p_vigencia_minutos IS NULL OR p_vigencia_minutos NOT BETWEEN 5 AND 60 THEN
        SET p_resultado = 'VIGENCIA_INVALIDA';
    ELSE
        SELECT COUNT(*) INTO v_usuario_existe
          FROM `usuario`
         WHERE `id_usuario` = p_id_usuario;

        SELECT COUNT(*) INTO v_admin_activo
          FROM `administrador`
         WHERE `id_admin` = p_id_admin AND `activo` = 1;

        SELECT COUNT(*) INTO v_ya_activada
          FROM `usuario`
         WHERE `id_usuario` = p_id_usuario
           AND (`hash_contrasena` LIKE '$2y$%'
             OR `hash_contrasena` LIKE '$2a$%'
             OR `hash_contrasena` LIKE '$2b$%'
             OR `hash_contrasena` LIKE '$argon2%');

        IF v_usuario_existe = 0 THEN
            SET p_resultado = 'USUARIO_INEXISTENTE';
        ELSEIF v_admin_activo = 0 THEN
            SET p_resultado = 'ADMIN_NO_AUTORIZADO';
        ELSEIF v_ya_activada > 0 THEN
            SET p_resultado = 'CUENTA_YA_ACTIVADA';
        ELSE
            START TRANSACTION;

                UPDATE `codigo_activacion`
                   SET `anulado_en` = NOW(6)
                 WHERE `id_usuario` = p_id_usuario
                   AND `usado_en` IS NULL
                   AND `anulado_en` IS NULL;

                INSERT INTO `codigo_activacion`
                    (`id_usuario`, `id_admin_emisor`, `hash_codigo`,
                     `emitido_en`, `expira_en`)
                VALUES
                    (p_id_usuario, p_id_admin, p_hash_codigo, NOW(6),
                     DATE_ADD(NOW(6), INTERVAL p_vigencia_minutos MINUTE));

                SET p_id_codigo = LAST_INSERT_ID();

                SELECT `expira_en` INTO p_expira_en
                  FROM `codigo_activacion`
                 WHERE `id_codigo` = p_id_codigo;

                INSERT INTO `accion_admin`
                    (`id_admin`, `fecha`, `tipo_accion`, `entidad`,
                     `id_objetivo`, `resultado`, `detalle`)
                VALUES
                    (p_id_admin, NOW(6), 'EMITIR_CODIGO', 'USUARIO',
                     p_id_usuario, 'EXITOSO',
                     CONCAT('Codigo ', p_id_codigo,
                            '; vigencia ', p_vigencia_minutos, ' min'));

            COMMIT;
            SET p_resultado = 'OK';
        END IF;
    END IF;
END$$

-- ---------------------------------------------------------------------
-- ACTIVACION
--   El script entrega SOLO el codigo en claro (no su hash, no su id):
--   el SP localiza la fila por hash_codigo, que es UNIQUE.
--
--   Garantias contra sobrescritura de una cuenta ya activada:
--     1. si hash_contrasena ya es un hash valido -> CUENTA_YA_ACTIVADA;
--     2. CAS: UPDATE ... WHERE hash_contrasena = v_hash_actual;
--     3. el codigo se marca usado en la misma transaccion.
--
--   Intentos: cada llamada con un codigo existente incrementa
--   `intentos` y el COMMIT lo conserva aunque la activacion falle.
--   Con 4 intentos el codigo queda bloqueado.
-- ---------------------------------------------------------------------
CREATE DEFINER='kiro_sp_definer'@'127.0.0.1' PROCEDURE `sp_activar_credencial`(
    IN  p_id_usuario  INT,
    IN  p_hash_codigo CHAR(64),
    IN  p_hash_nuevo  VARCHAR(255),
    IN  p_operador    VARCHAR(100),
    OUT p_resultado   VARCHAR(40)
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_id_codigo      BIGINT UNSIGNED DEFAULT NULL;
    DECLARE v_dueno          INT DEFAULT NULL;
    DECLARE v_expira         DATETIME(6) DEFAULT NULL;
    DECLARE v_usado          DATETIME(6) DEFAULT NULL;
    DECLARE v_anulado        DATETIME(6) DEFAULT NULL;
    DECLARE v_bloqueado      DATETIME(6) DEFAULT NULL;
    DECLARE v_intentos       INT DEFAULT 0;
    DECLARE v_hash_actual    VARCHAR(255) DEFAULT NULL;
    DECLARE v_existe_usuario INT DEFAULT 0;
    DECLARE v_resultado      VARCHAR(40) DEFAULT 'ERROR_INTERNO';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        IF p_id_usuario IN (1, 2) THEN
            INSERT INTO `historial_accion`
                (`tipo_accion`, `entidad_afectada`, `id_registro_afectado`,
                 `descripcion`, `fecha_accion`, `actor`, `resultado`, `id_usuario`)
            VALUES
                ('ACTIVACION_CUENTA', 'USUARIO', p_id_usuario,
                 'Activacion: ERROR_INTERNO', NOW(), 'ACTIVADOR',
                 'FALLIDO', p_id_usuario);
        END IF;
        SET p_resultado = 'ERROR_INTERNO';
    END;

    SET p_resultado = 'ERROR_INTERNO';

    IF p_id_usuario NOT IN (1, 2) THEN
        SET p_resultado = 'ID_NO_AUTORIZADO';
    ELSEIF p_hash_codigo IS NULL OR CHAR_LENGTH(p_hash_codigo) <> 64 THEN
        SET p_resultado = 'CODIGO_INVALIDO';
    ELSEIF p_hash_nuevo IS NULL
        OR CHAR_LENGTH(p_hash_nuevo) NOT BETWEEN 55 AND 255
        OR NOT (p_hash_nuevo LIKE '$2y$%'
             OR p_hash_nuevo LIKE '$2a$%'
             OR p_hash_nuevo LIKE '$2b$%'
             OR p_hash_nuevo LIKE '$argon2%') THEN
        SET p_resultado = 'HASH_NUEVO_INVALIDO';
    ELSE
        SELECT COUNT(*) INTO v_existe_usuario
          FROM `usuario`
         WHERE `id_usuario` = p_id_usuario;

        IF v_existe_usuario = 0 THEN
            SET p_resultado = 'USUARIO_INEXISTENTE';
        ELSE
            START TRANSACTION;

                SELECT `id_codigo`, `id_usuario`, `expira_en`, `usado_en`,
                       `anulado_en`, `bloqueado_en`, `intentos`
                  INTO v_id_codigo, v_dueno, v_expira, v_usado,
                       v_anulado, v_bloqueado, v_intentos
                  FROM `codigo_activacion`
                 WHERE `hash_codigo` = p_hash_codigo
                 FOR UPDATE;

                IF v_id_codigo IS NULL THEN
                    SET v_resultado = 'CODIGO_INVALIDO';
                ELSE
                    UPDATE `codigo_activacion`
                       SET `intentos` = `intentos` + 1
                     WHERE `id_codigo` = v_id_codigo;
                    SET v_intentos = v_intentos + 1;

                    IF v_dueno <> p_id_usuario THEN
                        SET v_resultado = 'CODIGO_INVALIDO';
                    ELSEIF v_intentos > 3 THEN
                        UPDATE `codigo_activacion`
                           SET `bloqueado_en` = COALESCE(`bloqueado_en`, NOW(6))
                         WHERE `id_codigo` = v_id_codigo;
                        SET v_resultado = 'INTENTOS_AGOTADOS';
                    ELSEIF v_bloqueado IS NOT NULL THEN
                        SET v_resultado = 'CODIGO_BLOQUEADO';
                    ELSEIF v_usado IS NOT NULL THEN
                        SET v_resultado = 'CODIGO_USADO';
                    ELSEIF v_anulado IS NOT NULL THEN
                        SET v_resultado = 'CODIGO_ANULADO';
                    ELSEIF v_expira < NOW(6) THEN
                        SET v_resultado = 'CODIGO_EXPIRADO';
                    ELSE
                        SELECT `hash_contrasena` INTO v_hash_actual
                          FROM `usuario`
                         WHERE `id_usuario` = p_id_usuario
                         FOR UPDATE;

                        IF v_hash_actual LIKE '$2y$%'
                        OR v_hash_actual LIKE '$2a$%'
                        OR v_hash_actual LIKE '$2b$%'
                        OR v_hash_actual LIKE '$argon2%' THEN
                            SET v_resultado = 'CUENTA_YA_ACTIVADA';
                        ELSE
                            UPDATE `usuario`
                               SET `hash_contrasena` = p_hash_nuevo
                             WHERE `id_usuario` = p_id_usuario
                               AND `hash_contrasena` = v_hash_actual;

                            IF ROW_COUNT() <> 1 THEN
                                SET v_resultado = 'CONFLICTO_ESTADO';
                            ELSE
                                UPDATE `codigo_activacion`
                                   SET `usado_en` = NOW(6)
                                 WHERE `id_codigo` = v_id_codigo
                                   AND `usado_en` IS NULL;

                                IF ROW_COUNT() <> 1 THEN
                                    SET v_resultado = 'CONFLICTO_ESTADO';
                                ELSE
                                    SET v_resultado = 'OK';
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                END IF;

                INSERT INTO `historial_accion`
                    (`tipo_accion`, `entidad_afectada`, `id_registro_afectado`,
                     `descripcion`, `fecha_accion`, `actor`, `resultado`, `id_usuario`)
                VALUES
                    ('ACTIVACION_CUENTA', 'USUARIO', p_id_usuario,
                     CONCAT('Activacion: ', v_resultado,
                            IF(v_id_codigo IS NULL, '', CONCAT('; codigo ', v_id_codigo)),
                            '; operador ', LEFT(COALESCE(p_operador, 'N/D'), 60)),
                     NOW(), 'ACTIVADOR',
                     IF(v_resultado = 'OK', 'EXITOSO', 'FALLIDO'), p_id_usuario);

            COMMIT;
            SET p_resultado = v_resultado;
        END IF;
    END IF;
END$$

DELIMITER ;
