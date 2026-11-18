<?php
/**
 * KIRO - Layout administrativo
 * Variables esperadas: $titulo, $paginaActiva, $contenido, $adminNombre, $adminCorreo
 */

$adminNombre = $adminNombre ?? SesionAdmin::nombre();
$adminCorreo = $adminCorreo ?? (string)($_SESSION['admin_correo'] ?? '');

function icono_admin(string $nombre, string $clase = ''): string {
    $trazos = [
        'panel'    => '<rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/>',
        'usuarios' => '<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>',
        'activar'  => '<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>',
        'bitacora' => '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/>',
        'salir'    => '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/>',
    ];
    $trazo = $trazos[$nombre] ?? $trazos['panel'];
    $claseAttr = trim("icono $clase");
    return '<svg class="' . htmlspecialchars($claseAttr, ENT_QUOTES, 'UTF-8') . '" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">' . $trazo . '</svg>';
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>KIRO Admin &middot; <?= htmlspecialchars($titulo, ENT_QUOTES, 'UTF-8') ?></title>
  <meta name="robots" content="noindex, nofollow">
  <link rel="stylesheet" href="../assets/css/app.css?v=4">
  <link rel="stylesheet" href="../assets/css/admin.css?v=1">
</head>
<body>

<div class="admin-raiz">

  <!-- ── Barra lateral ──────────────────────────────────────────── -->
  <aside class="admin-lateral" aria-label="Panel de administración">

    <div class="admin-marca">
      <div class="admin-marca-icono" aria-hidden="true">
        <?= icono_admin('panel') ?>
      </div>
      <div class="admin-marca-texto">
        <span class="admin-marca-nombre">KIRO</span>
        <span class="admin-marca-rol">Administración</span>
      </div>
    </div>

    <nav class="admin-menu" aria-label="Navegación administrativa">
      <a class="admin-menu-item<?= $paginaActiva === 'panel' ? ' is-activo' : '' ?>"
         href="index.php" <?= $paginaActiva === 'panel' ? 'aria-current="page"' : '' ?>>
        <?= icono_admin('panel') ?> <span>Panel</span>
      </a>
      <a class="admin-menu-item<?= $paginaActiva === 'usuarios' ? ' is-activo' : '' ?>"
         href="usuarios.php" <?= $paginaActiva === 'usuarios' ? 'aria-current="page"' : '' ?>>
        <?= icono_admin('usuarios') ?> <span>Usuarios</span>
      </a>
      <a class="admin-menu-item<?= $paginaActiva === 'activar' ? ' is-activo' : '' ?>"
         href="activar.php" <?= $paginaActiva === 'activar' ? 'aria-current="page"' : '' ?>>
        <?= icono_admin('activar') ?> <span>Activación</span>
      </a>
      <a class="admin-menu-item<?= $paginaActiva === 'bitacora' ? ' is-activo' : '' ?>"
         href="bitacora.php" <?= $paginaActiva === 'bitacora' ? 'aria-current="page"' : '' ?>>
        <?= icono_admin('bitacora') ?> <span>Bitácora</span>
      </a>
    </nav>

    <div class="admin-pie">
      <div class="admin-pie-info">
        <strong><?= htmlspecialchars($adminNombre, ENT_QUOTES, 'UTF-8') ?></strong>
        <?= htmlspecialchars($adminCorreo, ENT_QUOTES, 'UTF-8') ?>
      </div>
      <form class="admin-salir-form" method="post" action="logout.php">
        <input type="hidden" name="csrf" value="<?= htmlspecialchars(SesionAdmin::csrf(), ENT_QUOTES, 'UTF-8') ?>">
        <button type="submit" class="admin-salir-btn" title="Cerrar sesión administrativa">
          <?= icono_admin('salir') ?> <span>Cerrar sesión</span>
        </button>
      </form>
    </div>

  </aside>

  <!-- ── Área principal ─────────────────────────────────────────── -->
  <div class="admin-principal">
    <main class="admin-contenido" id="contenido">
      <?= $contenido ?>
    </main>
  </div>

</div>

</body>
</html>
