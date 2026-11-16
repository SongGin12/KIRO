<?php
/**
 * KIRO - Menu lateral
 * Variables esperadas: $paginaActiva (string)
 */

require_once __DIR__ . '/kiro-gato.php';

$menu = [
    ['clave' => 'inicio',  'texto' => 'Inicio',        'href' => 'index.php',         'icono' => 'inicio'],
    ['clave' => 'agenda',  'texto' => 'Agenda',        'href' => null,                'icono' => 'agenda'],
    ['clave' => 'notas',   'texto' => 'Notas',         'href' => null,                'icono' => 'notas'],
    ['clave' => 'kiro',    'texto' => 'KIRO',          'href' => null,                'icono' => 'kiro'],
    ['clave' => 'ajustes', 'texto' => 'Configuración', 'href' => 'configuracion.php', 'icono' => 'ajustes'],
];
?>
<aside class="barra-lateral">
  <div class="marca">
    <div class="marca-gato" aria-hidden="true">
      <?php kiro_gato('normal', 'gato--mini'); ?>
    </div>
    <div class="marca-texto">
      <span class="marca-nombre">KIRO</span>
      <span class="marca-lema">Tu mundo organizado</span>
    </div>
  </div>

  <nav class="menu" aria-label="Navegación principal">
    <?php foreach ($menu as $item): ?>
      <?php if ($item['href'] !== null): ?>
        <a class="menu-item<?= $paginaActiva === $item['clave'] ? ' is-activo' : '' ?>"
           href="<?= e($item['href']) ?>"
           <?= $paginaActiva === $item['clave'] ? 'aria-current="page"' : '' ?>>
          <?= icono($item['icono']) ?>
          <span><?= e($item['texto']) ?></span>
        </a>
      <?php else: ?>
        <span class="menu-item is-inactivo" aria-disabled="true"
              title="Se habilitará en una etapa siguiente">
          <?= icono($item['icono']) ?>
          <span><?= e($item['texto']) ?></span>
          <em class="menu-badge">pronto</em>
        </span>
      <?php endif; ?>
    <?php endforeach; ?>

    <span class="menu-item is-inactivo" aria-disabled="true"
          title="Requiere el sistema de autenticación (Etapa 2)">
      <?= icono('salir') ?>
      <span>Cerrar sesión</span>
      <em class="menu-badge">etapa 2</em>
    </span>
  </nav>

  <div class="barra-pie">
    <p class="barra-nota">
      Etapa 1<br>
      <strong>Estructura y datos reales</strong>
    </p>
  </div>
</aside>
