-- =====================================================================
-- KIRO - Vistas (4)
-- Exportado de MariaDB 10.4.32 (base Kiro) el 2026-11-15 22:46.
-- Las definiciones son las reales del servidor; se conserva el DEFINER.
-- Los DROP estan incluidos para permitir re-ejecucion: ejecutar este
-- archivo solo con un usuario administrador (los objetos usan DEFINER).
-- =====================================================================

USE Kiro;


-- -------------------------------------------------------------------
-- vw_kiro_proximas_citas: Citas futuras de un usuario, excluyendo las canceladas.
-- -------------------------------------------------------------------
DROP VIEW IF EXISTS vw_kiro_proximas_citas;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `kiro`.`vw_kiro_proximas_citas` AS select `kiro`.`cita`.`id_cita` AS `id_cita`,`kiro`.`cita`.`titulo` AS `titulo`,`kiro`.`cita`.`descripcion` AS `descripcion`,`kiro`.`cita`.`fecha_inicio` AS `fecha_inicio`,`kiro`.`cita`.`duracion_minutos` AS `duracion_minutos`,`kiro`.`cita`.`lugar` AS `lugar`,`kiro`.`cita`.`estado` AS `estado`,`kiro`.`cita`.`id_usuario` AS `id_usuario` from `kiro`.`cita` where `kiro`.`cita`.`fecha_inicio` >= current_timestamp() and `kiro`.`cita`.`estado` <> 'Cancelada';

-- -------------------------------------------------------------------
-- vw_kiro_actividades_pendientes: Actividades pendientes o en progreso, con el proyecto al que pertenecen.
-- -------------------------------------------------------------------
DROP VIEW IF EXISTS vw_kiro_actividades_pendientes;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `kiro`.`vw_kiro_actividades_pendientes` AS select `kiro`.`actividad`.`id_actividad` AS `id_actividad`,`kiro`.`actividad`.`titulo` AS `titulo`,`kiro`.`actividad`.`descripcion` AS `descripcion`,`kiro`.`actividad`.`fecha_limite` AS `fecha_limite`,`kiro`.`actividad`.`estado` AS `estado`,`kiro`.`actividad`.`prioridad` AS `prioridad`,`kiro`.`actividad`.`id_proyecto` AS `id_proyecto`,`kiro`.`actividad`.`id_usuario` AS `id_usuario` from `kiro`.`actividad` where `kiro`.`actividad`.`estado` = 'Pendiente';

-- -------------------------------------------------------------------
-- vw_kiro_proyectos_activos: Proyectos en progreso de un usuario, con su prioridad y fecha de fin.
-- -------------------------------------------------------------------
DROP VIEW IF EXISTS vw_kiro_proyectos_activos;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `kiro`.`vw_kiro_proyectos_activos` AS select `kiro`.`proyecto`.`id_proyecto` AS `id_proyecto`,`kiro`.`proyecto`.`nombre` AS `nombre`,`kiro`.`proyecto`.`descripcion` AS `descripcion`,`kiro`.`proyecto`.`fecha_inicio` AS `fecha_inicio`,`kiro`.`proyecto`.`fecha_fin` AS `fecha_fin`,`kiro`.`proyecto`.`estado` AS `estado`,`kiro`.`proyecto`.`prioridad` AS `prioridad`,`kiro`.`proyecto`.`id_usuario` AS `id_usuario` from `kiro`.`proyecto` where `kiro`.`proyecto`.`estado` <> 'Completado';

-- -------------------------------------------------------------------
-- vw_kiro_notas_categorias: Notas de un usuario junto a la categoria a la que pertenecen.
-- -------------------------------------------------------------------
DROP VIEW IF EXISTS vw_kiro_notas_categorias;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `kiro`.`vw_kiro_notas_categorias` AS select `n`.`id_nota` AS `id_nota`,`n`.`titulo` AS `nota`,`n`.`contenido` AS `contenido`,`n`.`fecha_creacion` AS `fecha_creacion`,`c`.`nombre` AS `categoria`,`c`.`tipo` AS `tipo_categoria`,`n`.`id_usuario` AS `id_usuario` from (`kiro`.`nota` `n` join `kiro`.`categoria` `c` on(`n`.`id_categoria` = `c`.`id_categoria`));
