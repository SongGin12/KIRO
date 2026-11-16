<?php
/**
 * KIRO - Personaje (gato 2D en SVG)
 * ---------------------------------------------------------------
 * Se dibuja una vez aquí y se reutiliza en cualquier vista:
 *
 *   require_once .../partials/kiro-gato.php;
 *   kiro_gato('normal');              // estado de reposo (parpadea)
 *   kiro_gato('feliz');               // ojos cerrados y sonrisa
 *   kiro_gato('pensativa');           // párpados entornados y mirada lateral
 *   kiro_gato('feliz', 'gato--mini'); // versión pequeña para el menu
 *
 * Estados disponibles: 'normal', 'feliz' y 'pensativa'.
 * Las animaciones viven en public/assets/css/kiro.css.
 *
 * El dibujo usa capas planas (sin degradados con id) para poder
 * repetir el personaje varias veces en la misma pagina sin ids duplicados.
 * Lienzo 400x400; trazo 2.2; paleta marfil, azul y melocotón.
 */

if (!function_exists('kiro_gato')) {
    function kiro_gato(string $estado = 'normal', string $clase = ''): void
    {
        $estado = in_array($estado, ['feliz', 'pensativa'], true) ? $estado : 'normal';
        $clase  = trim('gato ' . $clase);
        ?>
<div class="<?= e($clase) ?>" data-estado="<?= e($estado) ?>">
  <svg class="gato-svg" viewBox="40 24 320 336" role="img"
       aria-label="Kiro, el gato compañero de KIRO">
    <!-- Sombra de contacto (no se anima) -->
    <ellipse class="gato-sombra" cx="200" cy="342" rx="86" ry="8"/>

    <g class="gato-animado">

      <!-- Cola -->
      <g class="gato-cola">
        <path d="M240 328 C296 348 342 322 344 290 C345 274 338 262 328 258"
              fill="none" stroke="#3E4A5E" stroke-width="24" stroke-linecap="round"/>
        <path d="M240 328 C296 348 342 322 344 290 C345 274 338 262 328 258"
              fill="none" stroke="#FFF6EA" stroke-width="18.6" stroke-linecap="round"/>
        <path d="M254 331 C290 341 318 328 323 300" fill="none"
              stroke="#E9D5B8" stroke-width="4" stroke-linecap="round" opacity=".75"/>
      </g>

      <!-- Ancas -->
      <ellipse cx="146" cy="300" rx="26" ry="31" fill="#F6E7D2"
               stroke="#3E4A5E" stroke-width="2.2"/>
      <ellipse cx="254" cy="300" rx="26" ry="31" fill="#F6E7D2"
               stroke="#3E4A5E" stroke-width="2.2"/>
      <!-- Patas traseras -->
      <ellipse cx="142" cy="330" rx="15" ry="8.5" fill="#FFFBF2"
               stroke="#3E4A5E" stroke-width="2.2"/>
      <ellipse cx="258" cy="330" rx="15" ry="8.5" fill="#FFFBF2"
               stroke="#3E4A5E" stroke-width="2.2"/>

      <!-- Cuerpo -->
      <path d="M200 182 C228 182 247 196 251 222 C255 248 262 286 264 308
               C266 324 234 334 200 334 C166 334 134 324 136 308
               C138 286 145 248 149 222 C153 196 172 182 200 182 Z"
            fill="#FFF6EA" stroke="#3E4A5E" stroke-width="2.2"/>
      <ellipse cx="200" cy="196" rx="34" ry="9" fill="#E9D5B8" opacity=".32"/>
      <ellipse cx="246" cy="284" rx="13" ry="36" fill="#E9D5B8" opacity=".32"/>
      <path d="M143 240 C138 268 136 296 138 316" fill="none"
            stroke="#FFFDF8" stroke-width="3" stroke-linecap="round" opacity=".5"/>

      <!-- Patas delanteras -->
      <path d="M170 232 C169 268 168 300 170 316 C171 327 187 327 188 316
               C190 300 189 268 188 232"
            fill="#FFF6EA" stroke="#3E4A5E" stroke-width="2.2"/>
      <path d="M212 232 C211 268 210 300 212 316 C213 327 229 327 230 316
               C232 300 231 268 230 232"
            fill="#FFF6EA" stroke="#3E4A5E" stroke-width="2.2"/>
      <path d="M183 252 L183 312" stroke="#E9D5B8" stroke-width="5"
            stroke-linecap="round" opacity=".4"/>
      <path d="M219 252 L219 312" stroke="#E9D5B8" stroke-width="5"
            stroke-linecap="round" opacity=".4"/>
      <ellipse cx="177" cy="328" rx="16" ry="10" fill="#FFFBF2"
               stroke="#3E4A5E" stroke-width="2.2"/>
      <ellipse cx="223" cy="328" rx="16" ry="10" fill="#FFFBF2"
               stroke="#3E4A5E" stroke-width="2.2"/>
      <g class="gato-dedos" fill="none" stroke="#DCC9AC" stroke-width="1.5"
         stroke-linecap="round">
        <path d="M171 324 L171 333"/>
        <path d="M177 323 L177 335"/>
        <path d="M183 324 L183 333"/>
        <path d="M217 324 L217 333"/>
        <path d="M223 323 L223 335"/>
        <path d="M229 324 L229 333"/>
      </g>

      <!-- Pecho -->
      <path d="M200 206 C217 206 230 213 236 226 C240 236 235 247 226 251
               C218 255 182 255 174 251 C165 247 160 236 164 226
               C170 213 183 206 200 206 Z" fill="#FFFAF0"/>
      <ellipse cx="200" cy="252" rx="28" ry="6.5" fill="#EFDCC0" opacity=".32"/>

      <!-- Cabeza -->
      <g class="gato-cabeza">

        <!-- Orejas -->
        <g class="gato-oreja gato-oreja--izq">
          <path d="M147 96 C137 80 130 60 131 44 C132 37 139 35 145 41 C157 53 171 62 186 68 Z"
                fill="#FFF6EA" stroke="#3E4A5E" stroke-width="2.2" stroke-linejoin="round"/>
          <path d="M147 84 C140 70 136 56 136 46 C146 56 158 64 171 70 Z" fill="#EFC3BC"/>
        </g>
        <g class="gato-oreja gato-oreja--der">
          <path d="M253 96 C263 80 270 60 269 44 C268 37 261 35 255 41 C243 53 229 62 214 68 Z"
                fill="#FFF6EA" stroke="#3E4A5E" stroke-width="2.2" stroke-linejoin="round"/>
          <path d="M253 84 C260 70 264 56 264 46 C254 56 242 64 229 70 Z" fill="#EFC3BC"/>
        </g>

        <!-- Contorno de la cabeza -->
        <path d="M200 68 C223 68 241 76 253 90 C264 104 269 122 267 141
                 C265 161 256 178 240 189 C227 197 214 200 200 200
                 C186 200 173 197 160 189 C144 178 135 161 133 141
                 C131 122 136 104 147 90 C159 76 177 68 200 68 Z"
              fill="#FFF6EA" stroke="#3E4A5E" stroke-width="2.2"/>
        <ellipse cx="200" cy="192" rx="38" ry="9" fill="#EFDCC0" opacity=".4"/>
        <ellipse cx="200" cy="110" rx="32" ry="16" fill="#FFFDF8" opacity=".38"/>
        <path d="M144 104 C137 124 138 148 146 166" fill="none"
              stroke="#FFFDF8" stroke-width="3" stroke-linecap="round" opacity=".55"/>

        <!-- Mejillas -->
        <g class="gato-mejilla">
          <ellipse cx="153" cy="172" rx="11" ry="5.5" fill="#F5DCCF"/>
          <ellipse cx="247" cy="172" rx="11" ry="5.5" fill="#F5DCCF"/>
        </g>

        <!-- Ojos: estado normal -->
        <g class="ojos-normales">
          <path d="M161 135 C161 125 167 118 174 118 C182 118 188 126 188 135
                   C188 145 182 152 174 152 C166 152 161 145 161 135 Z" fill="#7FB0D0"/>
          <ellipse cx="174" cy="137" rx="5.2" ry="8" fill="#22304A"/>
          <circle cx="170" cy="128" r="3.2" fill="#FFFFFF"/>
          <circle cx="178" cy="144" r="1.6" fill="#DCEFFF"/>
          <path d="M161 132 C163 122 170 117 177 117" fill="none"
                stroke="#3E4A5E" stroke-width="2.2" stroke-linecap="round"/>

          <path d="M212 135 C212 125 218 118 226 118 C234 118 240 126 240 135
                   C240 145 234 152 226 152 C218 152 212 145 212 135 Z" fill="#7FB0D0"/>
          <ellipse cx="226" cy="137" rx="5.2" ry="8" fill="#22304A"/>
          <circle cx="222" cy="128" r="3.2" fill="#FFFFFF"/>
          <circle cx="230" cy="144" r="1.6" fill="#DCEFFF"/>
          <path d="M212 132 C214 122 221 117 228 117" fill="none"
                stroke="#3E4A5E" stroke-width="2.2" stroke-linecap="round"/>
        </g>

        <!-- Ojos: estado feliz -->
        <g class="ojos-feliz" fill="none" stroke="#3E4A5E" stroke-width="2.8"
           stroke-linecap="round">
          <path d="M162 138 C168 126 180 126 186 138"/>
          <path d="M214 138 C220 126 232 126 238 138"/>
        </g>

        <!-- Ojos: estado pensativa -->
        <g class="ojos-pensativa">
          <path d="M161 141 C161 133 167 127 174 127 C182 127 188 134 188 141
                   C188 148 182 153 174 153 C166 153 161 148 161 141 Z" fill="#7FB0D0"/>
          <ellipse cx="172" cy="143" rx="5" ry="7" fill="#22304A"/>
          <circle cx="169" cy="136" r="2.8" fill="#FFFFFF"/>
          <path d="M161 139 C163 131 170 126 177 126" fill="none"
                stroke="#3E4A5E" stroke-width="2.2" stroke-linecap="round"/>

          <path d="M212 141 C212 133 218 127 226 127 C234 127 240 134 240 141
                   C240 148 234 153 226 153 C218 153 212 148 212 141 Z" fill="#7FB0D0"/>
          <ellipse cx="224" cy="143" rx="5" ry="7" fill="#22304A"/>
          <circle cx="221" cy="136" r="2.8" fill="#FFFFFF"/>
          <path d="M212 139 C214 131 221 126 228 126" fill="none"
                stroke="#3E4A5E" stroke-width="2.2" stroke-linecap="round"/>
        </g>

        <!-- Hocico -->
        <ellipse cx="184" cy="167" rx="13" ry="8.5" fill="#FFFCF6"/>
        <ellipse cx="216" cy="167" rx="13" ry="8.5" fill="#FFFCF6"/>
        <g fill="#CDBBA0">
          <circle cx="178" cy="163" r="1.1"/>
          <circle cx="176" cy="170" r="1.1"/>
          <circle cx="182" cy="176" r="1.1"/>
          <circle cx="222" cy="163" r="1.1"/>
          <circle cx="224" cy="170" r="1.1"/>
          <circle cx="218" cy="176" r="1.1"/>
        </g>
        <path d="M193 160 C196 158 204 158 207 160 C206 165 203 168 200 168
                 C197 168 194 165 193 160 Z" fill="#DE9CA5"/>
        <ellipse cx="197" cy="161" rx="1.6" ry="1.1" fill="#F6C9CE" opacity=".85"/>

        <!-- Boca: estado normal -->
        <g class="boca-normal" fill="none" stroke="#4C5769" stroke-width="1.7"
           stroke-linecap="round">
          <path d="M200 168 C200 173 195 176 190 174"/>
          <path d="M200 168 C200 173 205 176 210 174"/>
        </g>

        <!-- Boca: estado feliz -->
        <g class="boca-feliz">
          <path d="M191 173 C195 182 205 182 209 173 C203 177 197 177 191 173 Z"
                fill="#6E3F4A"/>
          <ellipse cx="200" cy="177.5" rx="5" ry="3" fill="#F0B3B8"/>
        </g>

        <!-- Boca: estado pensativa -->
        <g class="boca-pensativa" fill="none" stroke="#4C5769" stroke-width="1.7"
           stroke-linecap="round">
          <path d="M194 176 C198 178 202 178 206 176"/>
        </g>

        <!-- Bigotes -->
        <g class="gato-bigotes" fill="none" stroke="#7A8497" stroke-width="1.2"
           stroke-linecap="round" opacity=".5">
          <path d="M166 163 L136 157"/>
          <path d="M164 170 L132 170"/>
          <path d="M166 177 L138 183"/>
          <path d="M234 163 L264 157"/>
          <path d="M236 170 L268 170"/>
          <path d="M234 177 L262 183"/>
        </g>
      </g>
    </g>

    <!-- Destellos (estado feliz) -->
    <g class="destellos">
      <path d="M316 112 l3.2 8 8 3.2 -8 3.2 -3.2 8 -3.2 -8 -8 -3.2 8 -3.2 z"
            fill="#AFCFEB"/>
      <path d="M82 156 l2.4 6 6 2.4 -6 2.4 -2.4 6 -2.4 -6 -6 -2.4 6 -2.4 z"
            fill="#AFCFEB"/>
    </g>

    <!-- Puntos suspensivos (estado pensativa) -->
    <g class="puntos-pensativa" fill="#AFCFEB">
      <circle cx="298" cy="120" r="3" opacity=".55"/>
      <circle cx="316" cy="102" r="3.9" opacity=".65"/>
      <circle cx="338" cy="82" r="4.8" opacity=".75"/>
    </g>
  </svg>
</div>
        <?php
    }
}
