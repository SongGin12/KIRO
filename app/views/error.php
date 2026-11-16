<?php
/**
 * KIRO - Pagina de error
 * Variable esperada: $mensaje (texto apto para el usuario, sin detalles técnicos)
 *
 * No usa el layout ni consulta la base de datos: si algo falla, esta
 * pagina tiene que poder mostrarse igual.
 */
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>KIRO &middot; No disponible</title>
  <link rel="stylesheet" href="assets/css/app.css">
  <link rel="stylesheet" href="assets/css/kiro.css">
</head>
<body class="cuerpo-error">
  <main class="error-pagina">
    <div class="error-gato" aria-hidden="true">
      <?php require_once __DIR__ . '/partials/kiro-gato.php'; kiro_gato('normal'); ?>
    </div>

    <h1>Algo no está disponible</h1>
    <p><?= e($mensaje ?? 'La página no pudo cargarse.') ?></p>

    <ul class="error-pistas">
      <li>Comprueba que MariaDB esté iniciado en el panel de XAMPP.</li>
      <li>Revisa que exista la base <code>Kiro</code>.</li>
      <li>Los detalles técnicos quedaron en <code>storage/logs/error.log</code>.</li>
    </ul>

    <a class="boton" href="index.php">Volver a Inicio</a>
  </main>
</body>
</html>
