<?php
/**
 * KIRO - Activacion de la contrasena de un usuario existente
 * =====================================================================
 * Herramienta local. Usa kiro_activador, que NO tiene privilegios de
 * tabla: solo puede ejecutar sp_activar_credencial.
 *
 * La contrasena nueva se lee de la variable de entorno KIRO_NUEVA_CLAVE
 * (o se pide por STDIN) y nunca se imprime. El codigo se pasa como
 * argumento, se convierte a SHA-256 y no se guarda en ningun lado.
 *
 * USO
 *   $env:KIRO_NUEVA_CLAVE = '...'
 *   php tools/activar_usuario.php --usuario=1 --codigo=<codigo>
 */

declare(strict_types=1);

$opciones = getopt('', ['usuario:', 'codigo:', 'ayuda']);
if (isset($opciones['ayuda']) || !isset($opciones['usuario'], $opciones['codigo'])) {
    fwrite(STDOUT, "Uso: php tools/activar_usuario.php --usuario=1 --codigo=<codigo>\n");
    fwrite(STDOUT, "La contrasena nueva se pasa en la variable KIRO_NUEVA_CLAVE.\n");
    exit(isset($opciones['ayuda']) ? 0 : 2);
}

$idUsuario = (int) $opciones['usuario'];
$codigo    = trim((string) $opciones['codigo']);

if (!preg_match('/^[a-f0-9]{64}$/i', $codigo)) {
    fwrite(STDERR, "El codigo debe tener 64 caracteres hexadecimales.\n");
    exit(2);
}

$clave = getenv('KIRO_NUEVA_CLAVE');
if ($clave === false || $clave === '') {
    fwrite(STDOUT, 'Nueva contrasena (se mostrara al escribir): ');
    $clave = rtrim((string) fgets(STDIN), "\r\n");
}
if (mb_strlen($clave) < 8 || strlen($clave) > 72) {
    fwrite(STDERR, "La contrasena debe tener entre 8 y 72 caracteres.\n");
    exit(2);
}

$raiz = dirname(__DIR__);
$cnf  = require $raiz . '/storage/secretos/activador.cnf.php';

try {
    $pdo = new PDO(
        sprintf('mysql:host=%s;port=%d;dbname=%s;charset=utf8mb4',
            $cnf['host'], (int) $cnf['puerto'], $cnf['nombre']),
        $cnf['usuario'],
        $cnf['clave'],
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_EMULATE_PREPARES => false]
    );
} catch (Throwable $e) {
    fwrite(STDERR, 'No se pudo conectar: ' . $e->getMessage() . "\n");
    exit(3);
}

$hashNuevo = password_hash($clave, PASSWORD_BCRYPT, ['cost' => 12]);
$hashCodigo = hash('sha256', $codigo);
$operador = getenv('USERNAME') ?: 'local';

try {
    $st = $pdo->prepare(
        'CALL sp_activar_credencial(:usuario, :hash_codigo, :hash_nuevo, :operador, @resultado)'
    );
    $st->execute([
        ':usuario'     => $idUsuario,
        ':hash_codigo' => $hashCodigo,
        ':hash_nuevo'  => $hashNuevo,
        ':operador'    => $operador,
    ]);

    $resultado = (string) $pdo->query('SELECT @resultado')->fetchColumn();
} catch (Throwable $e) {
    $resultado = 'ERROR_INTERNO';
    fwrite(STDERR, 'Fallo de base de datos: ' . $e->getMessage() . "\n");
}

// Registro local encadenado (sin codigo ni contrasena).
$log = $raiz . '/storage/logs/activacion.log';
$previo = is_file($log) ? (string) file_get_contents($log) : '';
$ultima = '';
if ($previo !== '') {
    $lineas = preg_split('/\r?\n/', trim($previo));
    $ultima = (string) end($lineas);
}
$evento = json_encode([
    'fecha'     => gmdate('c'),
    'usuario'   => $idUsuario,
    'resultado' => $resultado,
    'operador'  => $operador,
    'previo'    => $ultima === '' ? null : substr(hash('sha256', $ultima), 0, 16),
], JSON_UNESCAPED_SLASHES);
@file_put_contents($log, $evento . "\n", FILE_APPEND | LOCK_EX);

fwrite(STDOUT, 'Resultado: ' . $resultado . "\n");

exit($resultado === 'OK' ? 0 : 1);
