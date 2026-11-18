<?php
/**
 * KIRO Admin - Vista de inicio de sesión
 * Variables: $errores (array)
 */
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>KIRO &middot; Administración</title>
  <meta name="robots" content="noindex, nofollow">
  <link rel="stylesheet" href="../assets/css/app.css?v=4">
  <link rel="stylesheet" href="../assets/css/admin.css?v=1">
</head>
<body class="cuerpo-admin-login">

  <main>
    <section class="admin-login-tarjeta" aria-labelledby="admin-login-titulo">

      <div class="admin-login-marca">
        <div class="admin-login-icono" aria-hidden="true">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
               stroke-linecap="round" stroke-linejoin="round">
            <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
          </svg>
        </div>
        <div class="admin-login-texto">
          <span class="admin-login-nombre">KIRO</span>
          <span class="admin-login-rol">Panel de administración</span>
        </div>
      </div>

      <h1 id="admin-login-titulo">Acceso administrativo</h1>
      <p class="admin-login-intro">Esta área es exclusiva para administradores del sistema.</p>

      <?php if ($errores !== []): ?>
        <div class="admin-aviso admin-aviso--error" role="alert">
          <ul>
            <?php foreach ($errores as $err): ?>
              <li><?= htmlspecialchars($err, ENT_QUOTES, 'UTF-8') ?></li>
            <?php endforeach; ?>
          </ul>
        </div>
      <?php endif; ?>

      <form method="post" action="login.php" novalidate>
        <input type="hidden" name="csrf"
               value="<?= htmlspecialchars(SesionAdmin::csrf(), ENT_QUOTES, 'UTF-8') ?>">

        <div class="admin-login-campo">
          <label for="correo">Correo electrónico</label>
          <input type="email" id="correo" name="correo"
                 value="<?= htmlspecialchars($correo ?? '', ENT_QUOTES, 'UTF-8') ?>"
                 maxlength="150" autocomplete="username" required autofocus>
        </div>

        <div class="admin-login-campo">
          <label for="clave">Contraseña</label>
          <input type="password" id="clave" name="clave"
                 autocomplete="current-password" required>
        </div>

        <button type="submit" class="admin-login-btn">Entrar al panel</button>
      </form>

      <p class="admin-login-pie">
        ¿Eres usuario de KIRO?
        <a href="../login.php">Ir al acceso de usuario</a>
      </p>

    </section>
  </main>

</body>
</html>
