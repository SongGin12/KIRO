<?php
/**
 * KIRO - Panel de chat
 * Variables esperadas: $nombreCompanero
 *
 * IMPORTANTE: no hay IA conectada. Este panel demuestra la interfaz y
 * guarda los mensajes en sessionStorage del navegador; nada se envia a
 * MariaDB ni a ningun servicio externo.
 */
?>
<section class="chat" aria-labelledby="chat-titulo">
  <header class="chat-cabecera">
    <span class="chat-punto" aria-hidden="true"></span>
    <div class="chat-titulo-grupo">
      <h2 id="chat-titulo">Chat con <?= e($nombreCompanero) ?></h2>
      <p class="chat-subtitulo">Sin conexión a IA</p>
    </div>
    <button type="button" class="chat-limpiar" id="chat-limpiar"
            title="Vaciar la conversación guardada en esta pestaña">
      <?= icono('limpiar', 'icono icono--sm') ?>
      <span>Limpiar</span>
    </button>
  </header>

  <div class="chat-mensajes" id="chat-mensajes" role="log"
       aria-live="polite" aria-label="Mensajes de la conversación"></div>

  <form class="chat-form" id="chat-form" autocomplete="off">
    <label class="sr-only" for="chat-texto">Escribe un mensaje</label>
    <input id="chat-texto" name="mensaje" type="text" maxlength="500"
           placeholder="Escribe un mensaje..." required>
    <button type="submit" class="chat-enviar">Enviar</button>
  </form>

  <p class="chat-nota">
    Conversación local de prueba. <strong>No hay IA conectada</strong> y los
    mensajes no se guardan en MariaDB: solo en esta pestaña del navegador.
  </p>
</section>
