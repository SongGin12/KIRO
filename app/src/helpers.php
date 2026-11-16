<?php
/**
 * KIRO - Funciones auxiliares de presentacion
 * ---------------------------------------------------------------
 * Solo ayudan a mostrar datos. No contienen SQL.
 */

declare(strict_types=1);

/** Escapa texto antes de imprimirlo en HTML. */
function e(?string $texto): string
{
    return htmlspecialchars((string) $texto, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

/**
 * "domingo, 15 de noviembre de 2026"
 * Se escriben los nombres en español para no depender de setlocale ni de intl.
 */
function fecha_larga(string $fecha): string
{
    $dias  = ['domingo', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado'];
    $meses = [
        1 => 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
        'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];

    $dt = new DateTimeImmutable($fecha);

    return $dias[(int) $dt->format('w')]
        . ', ' . (int) $dt->format('j')
        . ' de ' . $meses[(int) $dt->format('n')]
        . ' de ' . $dt->format('Y');
}

/** "15 nov" o "15 nov 2027" si el ano no es el actual. */
function fecha_corta(string $fecha): string
{
    $meses = [
        1 => 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
        'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];

    $dt   = new DateTimeImmutable($fecha);
    $texto = (int) $dt->format('j') . ' ' . $meses[(int) $dt->format('n')];

    if ($dt->format('Y') !== (new DateTimeImmutable())->format('Y')) {
        $texto .= ' ' . $dt->format('Y');
    }

    return $texto;
}

/** "09:00" */
function hora(string $fechaHora): string
{
    return (new DateTimeImmutable($fechaHora))->format('H:i');
}

/** "09:00 - 10:00" a partir del inicio y la duracion en minutos. */
function rango_horario(string $fechaHora, int $duracionMinutos): string
{
    $inicio = new DateTimeImmutable($fechaHora);
    $fin    = $inicio->modify('+' . max(0, $duracionMinutos) . ' minutes');

    return $inicio->format('H:i') . ' - ' . $fin->format('H:i');
}

/**
 * Días de diferencia entre hoy y una fecha (sin hora).
 * Negativo = ya paso. 0 = hoy.
 */
function dias_para(string $fecha): int
{
    $hoy    = new DateTimeImmutable('today');
    $destino = new DateTimeImmutable(substr($fecha, 0, 10));

    return (int) $hoy->diff($destino)->format('%r%a');
}

/** Texto humano para una fecha limite. */
function texto_plazo(string $fecha): string
{
    $dias = dias_para($fecha);

    if ($dias === 0) {
        return 'vence hoy';
    }
    if ($dias === 1) {
        return 'vence mañana';
    }
    if ($dias > 1) {
        return 'en ' . $dias . ' días';
    }
    if ($dias === -1) {
        return 'venció ayer';
    }

    return 'venció hace ' . abs($dias) . ' días';
}

/** Clase CSS a partir del estado almacenado en la base de datos. */
function clase_estado(string $estado): string
{
    $mapa = [
        'pendiente'   => 'estado--pendiente',
        'en progreso' => 'estado--progreso',
        'completada'  => 'estado--listo',
        'completado'  => 'estado--listo',
        'confirmada'  => 'estado--listo',
        'cancelada'   => 'estado--cancelado',
    ];

    $clave = mb_strtolower(trim($estado));

    return $mapa[$clave] ?? 'estado--neutro';
}

/**
 * Iconos SVG en linea. Sin librerias ni fuentes externas.
 * Se devuelven como cadena para no repetir el mismo dibujo en cada vista.
 */
function icono(string $nombre, string $clase = 'icono'): string
{
    $trazos = [
        'inicio'   => '<path d="M3 10.5 12 3l9 7.5"/><path d="M5.5 9.5V20h13V9.5"/><path d="M10 20v-5h4v5"/>',
        'agenda'   => '<rect x="3" y="5" width="18" height="16" rx="3"/><path d="M8 3v4M16 3v4M3 10h18"/>',
        'notas'    => '<path d="M6 3h9l4 4v14H6z"/><path d="M15 3v5h5"/><path d="M9 13h7M9 17h5"/>',
        'kiro'     => '<path d="M5 9.5 4 4l5 2.5"/><path d="M19 9.5 20 4l-5 2.5"/><path d="M12 7c4 0 7 2.8 7 6.5S16 20 12 20s-7-2.8-7-6.5S8 7 12 7z"/><path d="M9.5 13h.01M14.5 13h.01"/><path d="M10.5 16.2c1 .8 2 .8 3 0"/>',
        'ajustes'  => '<circle cx="12" cy="12" r="3.2"/><path d="M12 2.8v2.4M12 18.8v2.4M4.5 7.5l2 1.2M17.5 15.3l2 1.2M4.5 16.5l2-1.2M17.5 8.7l2-1.2"/>',
        'salir'    => '<path d="M14 4H6v16h8"/><path d="M17 8l4 4-4 4"/><path d="M21 12H10"/>',
        'reloj'    => '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
        'lista'    => '<path d="M8 6h13M8 12h13M8 18h13"/><path d="M3.5 6h.01M3.5 12h.01M3.5 18h.01"/>',
        'proyecto' => '<path d="M3 7h6l2 2h10v10H3z"/><path d="M3 7V5h6l2 2"/>',
        'mas'      => '<path d="M12 5v14M5 12h14"/>',
        'limpiar'  => '<path d="M4 7h16"/><path d="M9 7V4h6v3"/><path d="M6 7l1 13h10l1-13"/>',
    ];

    $trazo = $trazos[$nombre] ?? $trazos['inicio'];

    return '<svg class="' . e($clase) . '" viewBox="0 0 24 24" fill="none" '
        . 'stroke="currentColor" stroke-width="1.8" stroke-linecap="round" '
        . 'stroke-linejoin="round" aria-hidden="true" focusable="false">'
        . $trazo . '</svg>';
}
