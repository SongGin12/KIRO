<?php
/**
 * KIRO - Vista Configuración (contenido)
 * Variables esperadas: $datos
 *
 * En la etapa 1 esta pagina es informativa: muestra el estado real de la
 * configuracion y de la conexion, y marca lo que aun no existe.
 */

$usuario = $datos['usuario'] ?? null;
$perfil  = $datos['perfil'] ?? null;
?>
<div class="pagina-simple">

  <header class="pagina-cabecera">
    <h1>Configuración</h1>
    <p>
      Estado real de la aplicación en esta primera etapa. Nada de lo que
      aparece aquí se guarda todavía: no hay formulario de preferencias.
    </p>
  </header>

  <section class="bloque" aria-labelledby="estado-titulo">
    <h2 id="estado-titulo">Estado actual</h2>

    <ul class="lista-estado">
      <li>
        <span class="lista-estado-clave">Base de datos</span>
        <span class="lista-estado-valor">MariaDB &middot; base <code>Kiro</code></span>
        <span class="estado estado--listo">conectada</span>
      </li>
      <li>
        <span class="lista-estado-clave">Conexión</span>
        <span class="lista-estado-valor">PDO con consultas preparadas</span>
        <span class="estado estado--listo">activa</span>
      </li>
      <li>
        <span class="lista-estado-clave">Zona horaria</span>
        <span class="lista-estado-valor">America/La_Paz (UTC-4)</span>
        <span class="estado estado--listo">aplicada</span>
      </li>
      <li>
        <span class="lista-estado-clave">Usuario de vista previa</span>
        <span class="lista-estado-valor">
          <?php if ($usuario !== null): ?>
            #<?= (int) $usuario['id_usuario'] ?> &middot; <?= e($usuario['nombre']) ?>
          <?php else: ?>
            no encontrado
          <?php endif; ?>
        </span>
        <span class="estado estado--pendiente">temporal</span>
      </li>
      <li>
        <span class="lista-estado-clave">Tema visual</span>
        <span class="lista-estado-valor">Pastel claro (fijo)</span>
        <span class="estado estado--pendiente">no editable</span>
      </li>
    </ul>

    <p class="bloque-nota">
      El usuario de vista previa se define en <code>app/config/config.php</code>
      con la clave <code>usuario_vista</code>. Desaparecerá cuando exista el
      inicio de sesión. No hay contraseñas almacenadas en la aplicación.
    </p>
  </section>

  <section class="bloque" aria-labelledby="perfil-titulo">
    <h2 id="perfil-titulo">Perfil del compañero</h2>

    <?php if ($perfil !== null): ?>
      <ul class="lista-estado">
        <li>
          <span class="lista-estado-clave">Nombre</span>
          <span class="lista-estado-valor"><?= e($perfil['nombre_companero']) ?></span>
        </li>
        <li>
          <span class="lista-estado-clave">Personalidad</span>
          <span class="lista-estado-valor"><?= e($perfil['personalidad']) ?></span>
        </li>
        <li>
          <span class="lista-estado-clave">Estilo de comunicación</span>
          <span class="lista-estado-valor"><?= e($perfil['estilo_comunicacion']) ?></span>
        </li>
        <li>
          <span class="lista-estado-clave">Color principal</span>
          <span class="lista-estado-valor"><?= e($perfil['color_principal']) ?></span>
        </li>
        <li>
          <span class="lista-estado-clave">Memoria</span>
          <span class="lista-estado-valor">
            <?= (int) $perfil['memoria_activa'] === 1 ? 'Activa' : 'Desactivada' ?>
          </span>
          <span class="estado estado--pendiente">solo lectura</span>
        </li>
      </ul>

      <p class="bloque-nota">
        Estos datos vienen de la tabla <code>PERFIL_KIRO</code>. Editarlos
        requiere definir antes la semántica de la memoria (decisión pendiente
        del plan técnico).
      </p>
    <?php else: ?>
      <p class="tarjeta-vacio">Este usuario no tiene perfil de compañero.</p>
    <?php endif; ?>
  </section>

  <section class="bloque" aria-labelledby="pendiente-titulo">
    <h2 id="pendiente-titulo">Pendiente para las siguientes etapas</h2>
    <ul class="lista-pendientes">
      <li>Autenticación, sesiones y cierre de sesión.</li>
      <li>Edición del perfil y preferencias del tema visual.</li>
      <li>Vistas Agenda, Notas y KIRO con sus formularios.</li>
      <li>Conexión real del chat (hoy es solo interfaz local).</li>
      <li>Auditoría en <code>HISTORIAL_ACCION</code> para cada operación.</li>
    </ul>
  </section>

</div>
