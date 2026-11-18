<?php
/**
 * KIRO - Vista de registro
 * Variables: $errores (array), $nombre (string), $correo (string)
 */
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>KIRO &middot; Crear cuenta</title>
  <link rel="stylesheet" href="assets/css/app.css?v=4">
  <link rel="stylesheet" href="assets/css/kiro.css?v=4">
  <link rel="stylesheet" href="assets/css/auth.css?v=1">
</head>
<body class="cuerpo-auth">

  <main class="auth">
    <section class="auth-tarjeta" aria-labelledby="registro-titulo">

      <div class="auth-marca">
        <span aria-hidden="true"><?php require_once KIRO_APP . '/views/partials/kiro-gato.php'; kiro_gato('normal', 'gato--mini'); ?></span>
        <span class="auth-marca-texto">
          <span class="auth-marca-nombre">KIRO</span>
          <span class="auth-marca-lema">Tu mundo organizado</span>
        </span>
      </div>

      <h1 id="registro-titulo">Crear cuenta</h1>
      <p class="auth-intro">Solo necesitas un correo y una contraseña. Cada cuenta ve únicamente sus propios datos.</p>

      <?php if ($errores !== []): ?>
        <div class="auth-aviso auth-aviso--error" role="alert">
          <ul>
            <?php foreach ($errores as $error): ?>
              <li><?= e($error) ?></li>
            <?php endforeach; ?>
          </ul>
        </div>
      <?php endif; ?>

      <form method="post" action="registro.php" novalidate>
        <input type="hidden" name="csrf" value="<?= e(Sesion::csrf()) ?>">

        <div class="auth-campo">
          <label for="nombre">Nombre</label>
          <input type="text" id="nombre" name="nombre" value="<?= e($nombre) ?>"
                 minlength="2" maxlength="100" autocomplete="name" required autofocus>
        </div>

        <div class="auth-campo">
          <label for="correo">Correo electrónico</label>
          <input type="email" id="correo" name="correo" value="<?= e($correo) ?>"
                 maxlength="150" autocomplete="email" required>
        </div>

        <div class="auth-campo">
          <label for="clave">Contraseña</label>
          <input type="password" id="clave" name="clave"
                 minlength="8" maxlength="72" autocomplete="new-password" required>
          <span class="auth-pista">Entre 8 y 72 caracteres.</span>
        </div>

        <div class="auth-campo">
          <label for="clave2">Repetir contraseña</label>
          <input type="password" id="clave2" name="clave2"
                 minlength="8" maxlength="72" autocomplete="new-password" required>
        </div>

        <button type="submit" class="auth-boton">Crear cuenta</button>
      </form>

      <p class="auth-pie">
        ¿Ya tienes cuenta?
        <a href="login.php">Iniciar sesión</a>
      </p>
    </section>
  </main>

</body>
</html>
