<?php
/**
 * KIRO - Emision de codigos de activacion (herramienta local)
 * =====================================================================
 * Genera un codigo de un solo uso para los usuarios 1 y 2 y lo muestra
 * UNA SOLA VEZ. En la base solo queda su SHA-256.
 *
 * El codigo se genera en PHP con random_bytes(32): MariaDB 10.4.32 no
 * tiene RANDOM_BYTES y RAND() no es criptograficamente seguro.
 *
 * USO
 *   php tools/emitir_codigo.php --usuario=1 --vigencia=30
 *
 * CREDENCIALES
 *   storage/secretos/admin.cnf.php (cuenta kiro_admin, ignorada por Git).
 */

declare(strict_types=1);

$opciones = getopt('', ['usuario:', 'admin::', 'vigencia::', 'ayuda']);
if (isset($opciones['ayuda']) || !isset($opciones['usuario'])) {
    fwrite(STDOUT, "Uso: php tools/emitir_codigo.php --usuario=1 [--admin=1] [--vigencia=30]\n");
    exit(isset($opciones['ayuda']) ? 0 : 2);
}

$idUsuario = (int) $opciones['usuario'];
$vigencia  = isset($opciones['vigencia']) ? (int) $opciones['vigencia'] : 30;

$raiz = dirname(__DIR__);
$cnf  = require $raiz . '/storage/secretos/admin.cnf.php';

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
    exit(2);
}

$idAdmin = isset($opciones['admin']) ? (int) $opciones['admin'] : null;
if ($idAdmin === null) {
    $idAdmin = (int) $pdo->query('SELECT id_admin FROM ADMINISTRADOR WHERE activo = 1 ORDER BY id_admin LIMIT 1')
        ->fetchColumn();
    if ($idAdmin <= 0) {
        fwrite(STDERR, "No hay administrador activo. Ejecuta tools/instalar_admin.php.\n");
        exit(2);
    }
}

$codigo = bin2hex(random_bytes(32));       // 256 bits de entropia
$hash   = hash('sha256', $codigo);

$st = $pdo->prepare(
    'CALL sp_emitir_codigo_activacion(:usuario, :admin, :hash, :vigencia,
                                      @id_codigo, @expira_en, @resultado)'
);
$st->execute([
    ':usuario'  => $idUsuario,
    ':admin'    => $idAdmin,
    ':hash'     => $hash,
    ':vigencia' => $vigencia,
]);

$res = $pdo->query('SELECT @id_codigo AS id_codigo, @expira_en AS expira_en, @resultado AS resultado')
    ->fetch();

fwrite(STDOUT, 'Resultado: ' . $res['resultado'] . "\n");

if ($res['resultado'] !== 'OK') {
    exit(1);
}

fwrite(STDOUT, "  usuario   : $idUsuario\n");
fwrite(STDOUT, '  id_codigo : ' . $res['id_codigo'] . "\n");
fwrite(STDOUT, '  expira    : ' . $res['expira_en'] . "\n");
fwrite(STDOUT, "  codigo    : $codigo\n");
fwrite(STDOUT, "Este codigo NO se puede recuperar. Entregalo al titular y no lo guardes.\n");
