<?php
/**
 * KIRO - Creacion del administrador inicial (herramienta local)
 * =====================================================================
 * Crea UNA fila en ADMINISTRADOR con contrasena aleatoria y la muestra
 * una sola vez. No se ejecuta desde el navegador.
 *
 * USO
 *   php tools/instalar_admin.php --correo=admin@kiro.local
 *
 * CREDENCIALES
 *   Usa storage/secretos/huella.cnf.php (cuenta administradora local).
 *   No guarda la clave en el repositorio.
 */

declare(strict_types=1);

$opciones = getopt('', ['correo::', 'nombre::', 'ayuda']);
if (isset($opciones['ayuda'])) {
    fwrite(STDOUT, "Uso: php tools/instalar_admin.php [--correo=admin@kiro.local] [--nombre=Administrador KIRO]\n");
    exit(0);
}

$raiz = dirname(__DIR__);
$cnf  = require $raiz . '/storage/secretos/huella.cnf.php';
$correo = strtolower(trim((string) ($opciones['correo'] ?? 'admin@kiro.local')));
$nombre = trim((string) ($opciones['nombre'] ?? 'Administrador KIRO'));

if (!filter_var($correo, FILTER_VALIDATE_EMAIL)) {
    fwrite(STDERR, "Correo invalido.\n");
    exit(2);
}

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

$st = $pdo->prepare('SELECT id_admin FROM ADMINISTRADOR WHERE correo = :correo LIMIT 1');
$st->execute([':correo' => $correo]);
$existente = $st->fetchColumn();
if ($existente !== false) {
    fwrite(STDERR, "Ya existe un administrador con ese correo (id $existente). No se crea otro.\n");
    exit(1);
}

$clave = bin2hex(random_bytes(24));
$hash  = password_hash($clave, PASSWORD_BCRYPT, ['cost' => 12]);

$st = $pdo->prepare(
    'INSERT INTO ADMINISTRADOR (nombre, correo, hash_contrasena_admin, activo, fecha_alta)
     VALUES (:nombre, :correo, :hash, 1, NOW())'
);
$st->execute([':nombre' => $nombre, ':correo' => $correo, ':hash' => $hash]);
$id = (int) $pdo->lastInsertId();

fwrite(STDOUT, "Administrador creado.\n");
fwrite(STDOUT, "  id     : $id\n");
fwrite(STDOUT, "  correo : $correo\n");
fwrite(STDOUT, "  clave  : $clave\n");
fwrite(STDOUT, "Guarda la clave en un lugar seguro: no se puede recuperar.\n");
