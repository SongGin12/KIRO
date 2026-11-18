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

    <form method="post" action="logout.php" class="menu-salir">
      <input type="hidden" name="csrf" value="<?= e(Sesion::csrf()) ?>">
      <button type="submit" class="menu-item menu-item--salir" title="Cerrar la sesión actual">
        <?= icono('salir') ?>
        <span>Cerrar sesión</span>
      </button>
    </form>
  </nav>

  <div class="barra-pie">
    <p class="barra-nota">
      Etapa 2<br>
      <strong>Acceso y datos privados</strong>
    </p>
  </div>
</aside>
