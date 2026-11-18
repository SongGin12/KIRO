<?php
/**
 * KIRO Admin - Vista de lista de usuarios
 * Variables: $usuarios (array con campo estado_activacion: 'activo'|'pendiente'|'desconocido')
 */
?>
<header class="admin-encabezado">
  <div>
    <h1>Usuarios</h1>
    <p>Consulta de cuentas registradas. No se muestran contraseñas ni datos privados.</p>
  </div>
</header>

<div class="admin-bloque">
  <h2 class="admin-bloque-titulo">Listado de cuentas
    <span style="font-weight: 400; text-transform: none; font-size: 12px; letter-spacing: 0; color: var(--admin-tinta-2);">
      — <?= count($usuarios) ?> usuario<?= count($usuarios) !== 1 ? 's' : '' ?>
    </span>
  </h2>

  <?php if (empty($usuarios)): ?>
    <p style="color: var(--admin-tinta-2);">No hay usuarios en la base de datos.</p>
  <?php else: ?>
    <div class="admin-tabla-wrap">
      <table class="admin-tabla">
        <thead>
          <tr>
            <th>#ID</th>
            <th>Nombre</th>
            <th>Correo electrónico</th>
            <th>Fecha de registro</th>
            <th>Contraseña</th>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($usuarios as $u):
            $estado = (string)($u['estado_activacion'] ?? 'pendiente');
          ?>
            <tr>
              <td><?= (int)$u['id_usuario'] ?></td>
              <td><?= htmlspecialchars((string)$u['nombre'], ENT_QUOTES, 'UTF-8') ?></td>
              <td class="correo"><?= htmlspecialchars((string)$u['correo'], ENT_QUOTES, 'UTF-8') ?></td>
              <td style="font-size: 12.5px; color: var(--admin-tinta-2); white-space: nowrap;">
                <?= htmlspecialchars(substr((string)$u['fecha_registro'], 0, 16), ENT_QUOTES, 'UTF-8') ?>
              </td>
              <td>
                <?php if ($estado === 'activo'): ?>
                  <span class="admin-hash-ok">Activada</span>
                <?php elseif ($estado === 'desconocido'): ?>
                  <span class="admin-hash-pendiente" title="Estado no determinable con estos permisos">—</span>
                <?php else: ?>
                  <span class="admin-hash-pendiente">Pendiente</span>
                <?php endif; ?>
              </td>
            </tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </div>
    <p style="margin-top: 14px; font-size: 12px; color: var(--admin-tinta-2);">
      El administrador no tiene acceso a notas, recuerdos, citas, proyectos,
      actividades, recursos ni información privada de cada usuario.
    </p>
  <?php endif; ?>
</div>
