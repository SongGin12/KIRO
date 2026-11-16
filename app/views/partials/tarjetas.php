<?php
/**
 * KIRO - Tarjetas informativas de Inicio
 * Variable esperada: $datos (resultado de RepositorioInicio::panelInicio)
 *
 * Ningun valor se escribe a mano: todo viene de MariaDB. Si una consulta
 * no devuelve filas se muestra un estado vacio, nunca un dato inventado.
 */

$cita       = $datos['proximaCita'] ?? null;
$ultimaCita = $datos['ultimaCita'] ?? null;
$resumen    = $datos['resumenActividad'] ?? ['total' => 0, 'proxima' => null, 'prioritarias' => 0];
$acts       = $datos['actividades'] ?? [];
$proyectos  = $datos['proyectos'] ?? [];
?>
<section class="tarjetas" aria-label="Resumen del dia">

  <!-- 1. Próxima cita ------------------------------------------------ -->
  <article class="tarjeta">
    <header class="tarjeta-cabecera">
      <span class="tarjeta-icono tarjeta-icono--azul"><?= icono('reloj') ?></span>
      <h2>Próxima cita</h2>
    </header>

    <?php if ($cita !== null): ?>
      <p class="tarjeta-dato">
        <?= e(fecha_corta($cita['fecha_inicio'])) ?>
        <span class="punto-sep" aria-hidden="true">&middot;</span>
        <?= e(rango_horario($cita['fecha_inicio'], (int) $cita['duracion_minutos'])) ?>
      </p>
      <p class="tarjeta-titulo"><?= e($cita['titulo']) ?></p>
      <p class="tarjeta-meta">
        <?= e($cita['lugar']) ?>
        <span class="estado <?= e(clase_estado($cita['estado'])) ?>"><?= e($cita['estado']) ?></span>
      </p>
    <?php else: ?>
      <p class="tarjeta-vacio">Sin citas próximas</p>
      <?php if ($ultimaCita !== null): ?>
        <p class="tarjeta-meta">
          Última: <?= e($ultimaCita['titulo']) ?>
          <span class="punto-sep" aria-hidden="true">&middot;</span>
          <?= e(fecha_corta($ultimaCita['fecha_inicio'])) ?>
        </p>
      <?php else: ?>
        <p class="tarjeta-meta">Todavía no hay citas registradas.</p>
      <?php endif; ?>
    <?php endif; ?>

    <footer class="tarjeta-pie">Origen: tabla <code>CITA</code></footer>
  </article>

  <!-- 2. Actividades pendientes -------------------------------------- -->
  <article class="tarjeta">
    <header class="tarjeta-cabecera">
      <span class="tarjeta-icono tarjeta-icono--amarillo"><?= icono('lista') ?></span>
      <h2>Actividades pendientes</h2>
    </header>

    <?php if ($resumen['total'] > 0): ?>
      <p class="tarjeta-numero">
        <?= (int) $resumen['total'] ?>
        <span><?= $resumen['total'] === 1 ? 'pendiente' : 'pendientes' ?></span>
      </p>

      <ul class="mini-lista">
        <?php foreach ($acts as $actividad): ?>
          <li>
            <span class="mini-titulo"><?= e($actividad['titulo']) ?></span>
            <span class="mini-meta">
              <?= e(texto_plazo($actividad['fecha_limite'])) ?>
              <?php if ($actividad['prioridad'] === 'Alta'): ?>
                <span class="punto-prioridad">prioridad alta</span>
              <?php endif; ?>
            </span>
          </li>
        <?php endforeach; ?>
      </ul>

      <?php if ($resumen['total'] > count($acts)): ?>
        <p class="tarjeta-meta">
          y <?= (int) $resumen['total'] - count($acts) ?> más
        </p>
      <?php endif; ?>
    <?php else: ?>
      <p class="tarjeta-vacio">Nada pendiente por ahora</p>
      <p class="tarjeta-meta">No hay actividades en estado Pendiente o En progreso.</p>
    <?php endif; ?>

    <footer class="tarjeta-pie">Origen: tabla <code>ACTIVIDAD</code></footer>
  </article>

  <!-- 3. Proyectos activos -------------------------------------------- -->
  <article class="tarjeta">
    <header class="tarjeta-cabecera">
      <span class="tarjeta-icono tarjeta-icono--lavanda"><?= icono('proyecto') ?></span>
      <h2>Proyectos activos</h2>
    </header>

    <?php if (count($proyectos) > 0): ?>
      <p class="tarjeta-numero">
        <?= count($proyectos) ?>
        <span>en progreso</span>
      </p>

      <ul class="mini-lista">
        <?php foreach ($proyectos as $proyecto): ?>
          <li>
            <span class="mini-titulo"><?= e($proyecto['nombre']) ?></span>
            <span class="mini-meta">
              Termina el <?= e(fecha_corta($proyecto['fecha_fin'])) ?>
              <?php if ($proyecto['prioridad'] === 'Alta'): ?>
                <span class="punto-prioridad">prioridad alta</span>
              <?php endif; ?>
            </span>
          </li>
        <?php endforeach; ?>
      </ul>
    <?php else: ?>
      <p class="tarjeta-vacio">Sin proyectos en progreso</p>
      <p class="tarjeta-meta">No hay filas con estado En progreso.</p>
    <?php endif; ?>

    <footer class="tarjeta-pie">Origen: tabla <code>PROYECTO</code></footer>
  </article>

</section>
