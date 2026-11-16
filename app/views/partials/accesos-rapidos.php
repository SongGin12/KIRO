<?php
/**
 * KIRO - Accesos rápidos horizontales
 *
 * Los formularios de alta todavía no existen (Agenda y Notas son de la
 * siguiente etapa). Por eso los botones informan en que etapa estara
 * disponible cada accion en lugar de abrir formularios falsos.
 */
$accesos = [
    ['texto' => 'Nueva cita',      'icono' => 'agenda',   'etapa' => 'Agenda'],
    ['texto' => 'Nueva nota',      'icono' => 'notas',    'etapa' => 'Notas'],
    ['texto' => 'Nuevo proyecto',  'icono' => 'proyecto', 'etapa' => 'Proyectos'],
    ['texto' => 'Añadir recuerdo', 'icono' => 'kiro',     'etapa' => 'KIRO'],
    ['texto' => 'Explorar recursos', 'icono' => 'lista',  'etapa' => 'Recursos'],
];
?>
<section class="accesos" aria-labelledby="accesos-titulo">
  <div class="accesos-cabecera">
    <h2 id="accesos-titulo">Accesos rápidos</h2>
    <p class="accesos-nota">
      Se habilitarán cuando existan las vistas Agenda, Notas y KIRO.
    </p>
  </div>

  <div class="accesos-fila">
    <?php foreach ($accesos as $acceso): ?>
      <button type="button" class="acceso"
              data-proximamente="<?= e($acceso['etapa']) ?>">
        <span class="acceso-icono"><?= icono($acceso['icono']) ?></span>
        <span class="acceso-texto"><?= e($acceso['texto']) ?></span>
      </button>
    <?php endforeach; ?>
  </div>
</section>
