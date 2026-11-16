<?php
/**
 * KIRO - Encabezado
 * Variables esperadas: $nombre, $nombreCompanero
 */

$ahora = new DateTimeImmutable('now');
?>
<header class="encabezado">
  <div class="encabezado-texto">
    <h1 class="saludo">
      Hola, <strong><?= e($nombre) ?></strong>
    </h1>
    <p class="encabezado-fecha">
      <span><?= e(fecha_larga($ahora->format('Y-m-d'))) ?></span>
      <span class="punto-sep" aria-hidden="true">&middot;</span>
      <time id="reloj" datetime="<?= e($ahora->format('c')) ?>"><?= e($ahora->format('H:i')) ?></time>
      <span class="encabezado-zona">Bolivia</span>
    </p>
  </div>

  <div class="encabezado-acciones">
    <span class="chip chip--aviso" title="No hay autenticación todavía">
      Vista previa &middot; sin sesión
    </span>
    <span class="chip chip--tema" title="Tema visual activo">
      <span class="chip-punto" aria-hidden="true"></span>
      Tema pastel
    </span>
    <a class="boton-ajustes" href="configuracion.php" title="Ir a configuración">
      <?= icono('ajustes') ?>
      <span>Ajustes</span>
    </a>
  </div>
</header>
