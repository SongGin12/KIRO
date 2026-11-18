<?php
/**
 * KIRO Admin - Vista de activación controlada
 * Variables: $errores, $mensaje, $usuariosActivables
 */
?>
<header class="admin-encabezado">
  <div>
    <h1>Activación controlada</h1>
    <p>Emisión de códigos para los usuarios 1 y 2. El código se entrega en pantalla una sola vez.</p>
  </div>
</header>

<?php if (!empty($mensaje)): ?>
  <div class="admin-aviso admin-aviso--ok" role="status">
    <?= htmlspecialchars($mensaje, ENT_QUOTES, 'UTF-8') ?>
  </div>
<?php endif; ?>

<?php if (!empty($errores)): ?>
  <div class="admin-aviso admin-aviso--error" role="alert">
    <ul>
      <?php foreach ($errores as $e): ?>
        <li><?= htmlspecialchars($e, ENT_QUOTES, 'UTF-8') ?></li>
      <?php endforeach; ?>
    </ul>
  </div>
<?php endif; ?>

<?php if (!empty($codigoEmitido)): ?>
  <div class="admin-bloque" style="border-color: rgba(58, 158, 110, .4);">
    <h2 class="admin-bloque-titulo" style="color: #6DCEA0;">Código de activación emitido</h2>
    <div class="admin-aviso admin-aviso--info" style="margin-bottom: 0;">
      <p style="font-size: 12.5px; margin-bottom: 8px; color: var(--admin-tinta-2);">
        Este código se muestra <strong>una sola vez</strong>. Cópialo y entrégalo al usuario
        para que ejecute <code>tools/activar_usuario.php</code>.
      </p>
      <code style="display: block; font-size: 14px; letter-spacing: .05em; word-break: break-all;
                   background: rgba(0,0,0,.2); padding: 12px 14px; border-radius: 8px;
                   color: #A0D8C8; border: 1px solid rgba(58, 158, 110, .3);">
        <?= htmlspecialchars($codigoEmitido, ENT_QUOTES, 'UTF-8') ?>
      </code>
      <p style="font-size: 11.5px; margin-top: 8px; color: var(--admin-tinta-2);">
        Usuario: #<?= (int)($idUsuarioActivado ?? 0) ?>
      </p>
    </div>
  </div>
<?php endif; ?>

<div class="admin-bloque">
  <h2 class="admin-bloque-titulo">Emitir código de activación</h2>

  <div class="admin-aviso admin-aviso--info" style="margin-bottom: 20px;">
    Solo se pueden activar los usuarios 1 y 2 desde este panel.
    Los usuarios 3 al 10 no se modifican. Los nuevos usuarios (&ge; 11) se registran
    con contraseña propia desde el formulario público.
  </div>

  <form method="post" action="activar.php" novalidate>
    <input type="hidden" name="csrf"
           value="<?= htmlspecialchars(SesionAdmin::csrf(), ENT_QUOTES, 'UTF-8') ?>">
    <input type="hidden" name="accion" value="emitir">

    <div style="margin-bottom: 16px;">
      <label style="display: block; margin-bottom: 8px; font-size: 12px; font-weight: 700;
                    color: var(--admin-tinta-2); letter-spacing: .04em; text-transform: uppercase;">
        Usuario a activar
      </label>
      <div class="admin-form-inline">
        <?php foreach ($usuariosActivables as $u):
          $activo = (bool)($u['ya_activo'] ?? false);
        ?>
          <label style="display: flex; align-items: center; gap: 8px; padding: 10px 14px;
                        border-radius: 10px; border: 1px solid var(--admin-borde);
                        background: var(--admin-sup-hover); cursor: <?= $activo ? 'default' : 'pointer' ?>;
                        font-size: 13.5px; color: <?= $activo ? 'var(--admin-tinta-2)' : 'var(--admin-tinta)' ?>;">
            <input type="radio" name="id_usuario" value="<?= (int)$u['id_usuario'] ?>"
                   <?= $activo ? 'disabled' : '' ?> required
                   style="accent-color: var(--admin-acento);">
            <span>
              #<?= (int)$u['id_usuario'] ?> — <?= htmlspecialchars((string)$u['nombre'], ENT_QUOTES, 'UTF-8') ?>
              &lt;<?= htmlspecialchars((string)$u['correo'], ENT_QUOTES, 'UTF-8') ?>&gt;
            </span>
            <?php if ($activo): ?>
              <span class="admin-hash-ok">Ya activado</span>
            <?php else: ?>
              <span class="admin-hash-pendiente">Pendiente</span>
            <?php endif; ?>
          </label>
        <?php endforeach; ?>
      </div>
    </div>

    <button type="submit" class="admin-btn" style="font-size: 13.5px; padding: 10px 20px;">
      Emitir código de activación
    </button>
  </form>
</div>

<div class="admin-bloque" style="border-color: var(--admin-borde);">
  <h2 class="admin-bloque-titulo">Procedimiento de activación</h2>
  <ol style="display: flex; flex-direction: column; gap: 8px; padding-left: 20px;
              font-size: 13.5px; color: var(--admin-tinta-2);">
    <li>El administrador emite el código desde este panel (se muestra una sola vez).</li>
    <li>El administrador entrega el código al usuario por un canal seguro.</li>
    <li>El usuario ejecuta en su equipo:<br>
        <code style="display: inline-block; margin-top: 4px; padding: 4px 10px;
                     background: rgba(0,0,0,.2); border-radius: 6px; font-size: 12px; color: #A0C8E0;">
          php tools/activar_usuario.php --usuario=1 --codigo=&lt;codigo&gt;
        </code>
    </li>
    <li>El SP <code>sp_activar_credencial</code> verifica el código y fija el hash de contraseña.</li>
    <li>El usuario puede iniciar sesión desde <a href="../login.php"
        style="color: #7FB8F8;">login.php</a>.</li>
  </ol>
</div>
