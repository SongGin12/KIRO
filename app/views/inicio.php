<?php
/**
 * KIRO - Vista Inicio
 * Variables esperadas: $datos
 *
 * Orden visual acordado:
 *   1. Personaje protagonista
 *   2. Tarjetas informativas
 *   3. Accesos rápidos
 *   (el chat va en la columna derecha)
 */

require_once __DIR__ . '/partials/kiro-gato.php';

$perfil          = $datos['perfil'] ?? null;
$nombreCompanero = $perfil['nombre_companero'] ?? 'Kiro';
$personalidad    = $perfil['personalidad'] ?? null;
$estilo          = $perfil['estilo_comunicacion'] ?? null;
$memoriaActiva   = (int) ($perfil['memoria_activa'] ?? 0) === 1;
$nombreUsuario   = $datos['usuario']['nombre'] ?? '';
?>
<div class="inicio-grid">

  <div class="inicio-columna">

    <!-- A. Personaje protagonista -->
    <section class="hero" aria-labelledby="hero-titulo">
      <p class="hero-etiqueta">Etapa 1 &middot; prototipo funcional</p>

      <button type="button" class="gato-boton" id="acariciar"
              aria-label="Acariciar a Kiro (animación de prueba)">
        <?php kiro_gato('normal'); ?>
      </button>

      <h2 class="hero-titulo" id="hero-titulo">
        Hola<?= $nombreUsuario !== '' ? ', ' . e($nombreUsuario) : '' ?>.
        Soy <strong><?= e($nombreCompanero) ?></strong>.
      </h2>

      <p class="hero-mensaje">
        Este es tu espacio. Lo que ves aquí sale de tu base de datos en
        MariaDB: tu próxima cita, lo que tienes pendiente y tus proyectos
        en curso. Todavía no converso contigo; el chat de la derecha es
        solo la interfaz de la siguiente etapa.
      </p>

      <div class="hero-chips">
        <?php if ($personalidad !== null): ?>
          <span class="chip chip--suave">Personalidad: <?= e($personalidad) ?></span>
        <?php endif; ?>
        <?php if ($estilo !== null): ?>
          <span class="chip chip--suave">Estilo: <?= e($estilo) ?></span>
        <?php endif; ?>
        <span class="chip chip--suave">
          Memoria <?= $memoriaActiva ? 'activa' : 'desactivada' ?>
        </span>
      </div>

      <p class="hero-pista">Haz clic en <?= e($nombreCompanero) ?></p>
    </section>

    <!-- B. Tarjetas informativas -->
    <?php require __DIR__ . '/partials/tarjetas.php'; ?>

    <!-- C. Accesos rápidos -->
    <?php require __DIR__ . '/partials/accesos-rapidos.php'; ?>

  </div>

  <!-- D. Panel derecho: chat -->
  <aside class="inicio-chat">
    <?php require __DIR__ . '/partials/chat.php'; ?>
  </aside>

</div>
