<?php
/**
 * KIRO Admin - Vista de bitácora completa
 * Variables: $acciones (array)
 */
?>
<header class="admin-encabezado">
  <div>
    <h1>Bitácora</h1>
    <p>Registro de todas las acciones administrativas del sistema.</p>
  </div>
</header>

<div class="admin-bloque">
  <h2 class="admin-bloque-titulo">Acciones registradas
    <span style="font-weight: 400; text-transform: none; font-size: 12px; letter-spacing: 0; color: var(--admin-tinta-2);">
      — <?= count($acciones) ?> registros
    </span>
  </h2>

  <?php if (empty($acciones)): ?>
    <p style="color: var(--admin-tinta-2); font-size: 13.5px;">
      No hay acciones registradas en la bitácora.
    </p>
  <?php else: ?>
    <div class="admin-tabla-wrap">
      <table class="admin-tabla">
        <thead>
          <tr>
            <th>Fecha</th>
            <th>Administrador</th>
            <th>Tipo</th>
            <th>Entidad</th>
            <th>Objetivo</th>
            <th>Resultado</th>
            <th>Detalle</th>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($acciones as $acc): ?>
            <tr>
              <td style="font-size: 12px; white-space: nowrap; color: var(--admin-tinta-2);">
                <?= htmlspecialchars(substr((string)$acc['fecha'], 0, 19), ENT_QUOTES, 'UTF-8') ?>
              </td>
              <td style="font-size: 12.5px;">
                <?= htmlspecialchars((string)($acc['admin_nombre'] ?? '—'), ENT_QUOTES, 'UTF-8') ?>
              </td>
              <td>
                <span class="admin-bitacora-tipo" style="font-size: 11px;">
                  <?= htmlspecialchars((string)$acc['tipo_accion'], ENT_QUOTES, 'UTF-8') ?>
                </span>
              </td>
              <td style="font-size: 12.5px; color: var(--admin-tinta-2);">
                <?= htmlspecialchars((string)$acc['entidad'], ENT_QUOTES, 'UTF-8') ?>
              </td>
              <td style="font-size: 12.5px; text-align: center;">
                <?= $acc['id_objetivo'] !== null ? (int)$acc['id_objetivo'] : '—' ?>
              </td>
              <td>
                <span class="admin-bitacora-resultado <?= strtolower((string)$acc['resultado']) === 'ok' ? 'ok' : 'error' ?>">
                  <?= htmlspecialchars((string)$acc['resultado'], ENT_QUOTES, 'UTF-8') ?>
                </span>
              </td>
              <td style="font-size: 12.5px; color: var(--admin-tinta-2); max-width: 240px;
                         overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"
                  title="<?= htmlspecialchars((string)$acc['detalle'], ENT_QUOTES, 'UTF-8') ?>">
                <?= htmlspecialchars((string)$acc['detalle'], ENT_QUOTES, 'UTF-8') ?>
              </td>
            </tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </div>
  <?php endif; ?>
</div>
