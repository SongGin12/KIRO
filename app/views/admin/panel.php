<?php
/**
 * KIRO Admin - Vista del panel principal
 * Variables: $stats, $ultimasAcciones
 */
?>
<header class="admin-encabezado">
  <div>
    <h1>Panel de administración</h1>
    <p>Visión general del sistema KIRO.</p>
  </div>
  <span class="admin-badge">
    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor"
         stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
      <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
    </svg>
    <?= htmlspecialchars(date('d/m/Y H:i'), ENT_QUOTES, 'UTF-8') ?> Bolivia
  </span>
</header>

<div class="admin-stats">
  <div class="admin-stat">
    <div class="admin-stat-etiqueta">Usuarios totales</div>
    <div class="admin-stat-valor"><?= (int)($stats['total_usuarios'] ?? 0) ?></div>
    <div class="admin-stat-nota">Incluye originales y nuevos</div>
  </div>
  <div class="admin-stat">
    <div class="admin-stat-etiqueta">Cuentas activas</div>
    <div class="admin-stat-valor"><?= (int)($stats['usuarios_activos'] ?? 0) ?></div>
    <div class="admin-stat-nota">Hash bcrypt válido</div>
  </div>
  <div class="admin-stat">
    <div class="admin-stat-etiqueta">Sin activar</div>
    <div class="admin-stat-valor"><?= (int)($stats['usuarios_pendientes'] ?? 0) ?></div>
    <div class="admin-stat-nota">Hash de relleno</div>
  </div>
  <div class="admin-stat">
    <div class="admin-stat-etiqueta">Acciones hoy</div>
    <div class="admin-stat-valor"><?= (int)($stats['acciones_hoy'] ?? 0) ?></div>
    <div class="admin-stat-nota">Registradas en bitácora</div>
  </div>
</div>

<div class="admin-bloque">
  <h2 class="admin-bloque-titulo">Últimas acciones registradas</h2>

  <?php if (empty($ultimasAcciones)): ?>
    <p style="color: var(--admin-tinta-2); font-size: 13.5px;">
      Todavía no hay acciones registradas en la bitácora.
    </p>
  <?php else: ?>
    <div class="admin-bitacora">
      <?php foreach ($ultimasAcciones as $acc): ?>
        <div class="admin-bitacora-fila">
          <span class="admin-bitacora-fecha">
            <?= htmlspecialchars(substr((string)$acc['fecha'], 0, 16), ENT_QUOTES, 'UTF-8') ?>
          </span>
          <span class="admin-bitacora-tipo">
            <?= htmlspecialchars((string)$acc['tipo_accion'], ENT_QUOTES, 'UTF-8') ?>
          </span>
          <span class="admin-bitacora-detalle" title="<?= htmlspecialchars((string)$acc['detalle'], ENT_QUOTES, 'UTF-8') ?>">
            <?= htmlspecialchars((string)$acc['detalle'], ENT_QUOTES, 'UTF-8') ?>
          </span>
          <span class="admin-bitacora-resultado <?= strtolower((string)$acc['resultado']) === 'ok' ? 'ok' : 'error' ?>">
            <?= htmlspecialchars((string)$acc['resultado'], ENT_QUOTES, 'UTF-8') ?>
          </span>
        </div>
      <?php endforeach; ?>
    </div>
  <?php endif; ?>
</div>

<div class="admin-bloque">
  <h2 class="admin-bloque-titulo">Accesos rápidos</h2>
  <div style="display: flex; gap: 10px; flex-wrap: wrap;">
    <a href="usuarios.php" class="admin-btn">Ver todos los usuarios</a>
    <a href="activar.php" class="admin-btn">Emitir código de activación</a>
    <a href="bitacora.php" class="admin-btn">Bitácora completa</a>
  </div>
</div>
