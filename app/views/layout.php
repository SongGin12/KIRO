<?php
/**
 * KIRO - Layout general
 * Variables esperadas: $titulo, $paginaActiva, $contenido, $datos
 */

$usuario         = $datos['usuario'] ?? null;
$perfil          = $datos['perfil'] ?? null;
$nombre          = $usuario['nombre'] ?? '';
$nombreCompanero = $perfil['nombre_companero'] ?? 'Kiro';
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>KIRO &middot; <?= e($titulo) ?></title>
  <meta name="description" content="KIRO, tu mundo organizado con un compañero a tu lado.">
  <link rel="stylesheet" href="assets/css/app.css?v=3">
  <link rel="stylesheet" href="assets/css/kiro.css?v=3">
</head>
<body data-pagina="<?= e($paginaActiva) ?>">

  <a class="salto-contenido" href="#contenido">Ir al contenido</a>

  <div class="app">
    <?php require __DIR__ . '/partials/sidebar.php'; ?>

    <div class="app-principal">
      <?php require __DIR__ . '/partials/header.php'; ?>

      <main class="contenido" id="contenido">
        <?= $contenido ?>
      </main>
    </div>
  </div>

  <div class="aviso" id="aviso" role="status" aria-live="polite"></div>

  <script src="assets/js/app.js?v=3"></script>
</body>
</html>
