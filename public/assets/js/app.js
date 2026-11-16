/* =====================================================================
   KIRO - JavaScript de la interfaz (sin librerias)
   ---------------------------------------------------------------------
   1. Reloj del encabezado (zona horaria de Bolivia)
   2. Personaje: estado feliz al hacer clic
   3. Chat local de prueba (sessionStorage, sin IA, sin MariaDB)
   4. Accesos rápidos: aviso de etapa pendiente
   ===================================================================== */

(function () {
  'use strict';

  /* ---------------------------- Utilidades ------------------------- */
  function $(selector, contexto) {
    return (contexto || document).querySelector(selector);
  }

  function $$(selector, contexto) {
    return Array.prototype.slice.call(
      (contexto || document).querySelectorAll(selector)
    );
  }

  var temporizadorAviso = null;

  function mostrarAviso(texto) {
    var aviso = $('#aviso');
    if (!aviso) {
      return;
    }

    aviso.textContent = texto;
    aviso.classList.add('is-visible');

    window.clearTimeout(temporizadorAviso);
    temporizadorAviso = window.setTimeout(function () {
      aviso.classList.remove('is-visible');
    }, 3400);
  }

  /* ------------------------- 1. Reloj del header ------------------- */
  function iniciarReloj() {
    var reloj = $('#reloj');
    if (!reloj) {
      return;
    }

    var formato;
    try {
      formato = new Intl.DateTimeFormat('es-BO', {
        hour: '2-digit',
        minute: '2-digit',
        hour12: false,
        timeZone: 'America/La_Paz'
      });
    } catch (e) {
      formato = null;
    }

    function pintar() {
      var ahora = new Date();
      reloj.textContent = formato
        ? formato.format(ahora)
        : String(ahora.getHours()).padStart(2, '0') + ':' +
          String(ahora.getMinutes()).padStart(2, '0');
    }

    pintar();
    window.setInterval(pintar, 15000);
  }

  /* --------------------- 2. Personaje: acariciar ------------------ */
  function iniciarPersonaje() {
    var boton = $('#acariciar');
    if (!boton) {
      return;
    }

    var gato = $('.gato', boton);
    if (!gato) {
      return;
    }

    var temporizador = null;

    boton.addEventListener('click', function () {
      gato.setAttribute('data-estado', 'feliz');

      window.clearTimeout(temporizador);
      temporizador = window.setTimeout(function () {
        gato.setAttribute('data-estado', 'normal');
      }, 2400);
    });
  }

  /* ------------------- 3. Chat local (sin IA) --------------------- */
  var CLAVE_CHAT = 'kiro.chat.v1';

  var MENSAJE_INICIAL = {
    tipo: 'sistema',
    texto: 'Chat de prueba. No hay IA conectada y nada se guarda en MariaDB: ' +
           'los mensajes viven solo en esta pestaña.'
  };

  function leerConversacion() {
    try {
      var crudo = window.sessionStorage.getItem(CLAVE_CHAT);
      if (!crudo) {
        return [];
      }
      var datos = JSON.parse(crudo);
      return Array.isArray(datos) ? datos : [];
    } catch (e) {
      return [];
    }
  }

  function guardarConversacion(mensajes) {
    try {
      window.sessionStorage.setItem(CLAVE_CHAT, JSON.stringify(mensajes));
    } catch (e) {
      /* Si el navegador bloquea sessionStorage, el chat sigue funcionando
         en memoria durante esta pagina. */
    }
  }

  function pintarConversacion(contenedor, mensajes) {
    contenedor.textContent = '';

    mensajes.forEach(function (mensaje) {
      var burbuja = document.createElement('div');
      burbuja.className = 'mensaje mensaje--' +
        (mensaje.tipo === 'usuario' ? 'usuario' : 'sistema');

      // textContent evita interpretar HTML escrito por el usuario.
      burbuja.textContent = mensaje.texto;

      contenedor.appendChild(burbuja);
    });

    contenedor.scrollTop = contenedor.scrollHeight;
  }

  function iniciarChat() {
    var form = $('#chat-form');
    var entrada = $('#chat-texto');
    var contenedor = $('#chat-mensajes');
    var botonLimpiar = $('#chat-limpiar');

    if (!form || !entrada || !contenedor) {
      return;
    }

    var mensajes = leerConversacion();

    if (mensajes.length === 0) {
      mensajes.push(MENSAJE_INICIAL);
      guardarConversacion(mensajes);
    }

    pintarConversacion(contenedor, mensajes);

    form.addEventListener('submit', function (evento) {
      evento.preventDefault();

      var texto = entrada.value.trim();
      if (texto === '') {
        return;
      }

      mensajes.push({ tipo: 'usuario', texto: texto });
      guardarConversacion(mensajes);
      pintarConversacion(contenedor, mensajes);

      entrada.value = '';
      entrada.focus();

      mostrarAviso('Mensaje guardado solo en esta pestaña. Sin IA conectada.');
    });

    if (botonLimpiar) {
      botonLimpiar.addEventListener('click', function () {
        mensajes = [MENSAJE_INICIAL];
        guardarConversacion(mensajes);
        pintarConversacion(contenedor, mensajes);
        mostrarAviso('Conversación local vaciada.');
      });
    }
  }

  /* ---------------------- 4. Accesos rápidos ---------------------- */
  function iniciarAccesos() {
    $$('[data-proximamente]').forEach(function (boton) {
      boton.addEventListener('click', function () {
        var etapa = boton.getAttribute('data-proximamente');
        mostrarAviso('"' + etapa + '" se habilitará en la siguiente etapa.');
      });
    });
  }

  /* ---------------------------- Arranque -------------------------- */
  document.addEventListener('DOMContentLoaded', function () {
    iniciarReloj();
    iniciarPersonaje();
    iniciarChat();
    iniciarAccesos();
  });
})();
