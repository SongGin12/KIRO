<?php
/**
 * KIRO - Huella de conservacion (herramienta local, NO forma parte de la app)
 * =====================================================================
 * Calcula un SHA-256 canonico de cada tabla de la base Kiro para poder
 * demostrar que los datos academicos no cambiaron durante la entrega de
 * autenticacion.
 *
 * USO
 *   php tools/huella.php --puerto=3309 --salida=storage/evidencias/huella_b0.json
 *
 * CREDENCIALES
 *   Lee storage/secretos/huella.cnf.php (ignorado por Git) con la forma:
 *     return ['host'=>'127.0.0.1','puerto'=>3309,'usuario'=>'root',
 *             'clave'=>'...','nombre'=>'Kiro'];
 *   Es una herramienta de verificacion local: puede usar una cuenta
 *   administrativa porque NO es la conexion de la aplicacion.
 *
 * SERIALIZACION v1 (documentada en docs/evidencias/13_login_y_aislamiento)
 *   - Columnas en ORDINAL_POSITION; filas ordenadas por clave primaria.
 *   - NULL            -> "N"
 *   - valor no nulo   -> "V" + longitud(HEX) en 10 digitos + ":" + HEX
 *   - separador campo -> "|"   separador fila -> "\n"
 *   - USUARIO.hash_contrasena se sustituye por SHA-256 (nunca se escribe)
 *   - Fechas en UTC; los DATETIME(6) conservan microsegundos.
 */

declare(strict_types=1);

const SERIALIZADOR_VERSION = 1;

$opciones = getopt('', ['puerto::', 'salida::', 'ayuda']);
if (isset($opciones['ayuda'])) {
    fwrite(STDOUT, "Uso: php tools/huella.php [--puerto=3309] [--salida=ruta.json]\n");
    exit(0);
}

$raiz = dirname(__DIR__);
$rutaCnf = $raiz . '/storage/secretos/huella.cnf.php';
if (!is_file($rutaCnf)) {
    fwrite(STDERR, "Falta storage/secretos/huella.cnf.php\n");
    exit(2);
}
$cnf = require $rutaCnf;
if (isset($opciones['puerto']) && $opciones['puerto'] !== false) {
    $cnf['puerto'] = (int) $opciones['puerto'];
}

$salida = $opciones['salida'] ?? ($raiz . '/storage/evidencias/huella.json');
if (!is_dir(dirname($salida))) {
    mkdir(dirname($salida), 0775, true);
}

try {
    $pdo = new PDO(
        sprintf('mysql:host=%s;port=%d;dbname=%s;charset=utf8mb4',
            $cnf['host'], (int) $cnf['puerto'], $cnf['nombre']),
        $cnf['usuario'],
        $cnf['clave'],
        [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_EMULATE_PREPARES   => false,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_STRINGIFY_FETCHES  => true,
        ]
    );
    // Contexto que hace reproducible la serializacion.
    $pdo->exec("SET NAMES utf8mb4");
    $pdo->exec("SET time_zone = '+00:00'");
} catch (Throwable $e) {
    fwrite(STDERR, 'No se pudo conectar: ' . $e->getMessage() . "\n");
    exit(2);
}

/** Convierte un valor escalar a su forma canonica v1. */
function valor_canonico(?string $valor): string
{
    if ($valor === null) {
        return 'N';
    }
    $hex = strtoupper(bin2hex($valor));

    return 'V' . str_pad((string) strlen($hex), 10, '0', STR_PAD_LEFT) . ':' . $hex;
}

$tablas = $pdo->query(
    "SELECT TABLE_NAME FROM information_schema.TABLES
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_TYPE = 'BASE TABLE'
      ORDER BY TABLE_NAME"
)->fetchAll(PDO::FETCH_COLUMN);

$manifiesto = [
    'serializador_version' => SERIALIZADOR_VERSION,
    'script_sha256'        => hash_file('sha256', __FILE__),
    'servidor'             => $pdo->query('SELECT VERSION()')->fetchColumn(),
    'base'                 => $cnf['nombre'],
    'charset'              => 'utf8mb4',
    'zona_horaria_sesion'  => '+00:00',
    'generado_en'          => gmdate('Y-m-d\TH:i:s\Z'),
    'tablas'               => [],
];

foreach ($tablas as $tabla) {
    // Columnas y clave primaria reales (no se asumen nombres fijos).
    $st = $pdo->prepare(
        "SELECT COLUMN_NAME FROM information_schema.COLUMNS
          WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?
          ORDER BY ORDINAL_POSITION"
    );
    $st->execute([$tabla]);
    $columnas = $st->fetchAll(PDO::FETCH_COLUMN);

    $st = $pdo->prepare(
        "SELECT COLUMN_NAME FROM information_schema.KEY_COLUMN_USAGE
          WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?
            AND CONSTRAINT_NAME = 'PRIMARY'
          ORDER BY ORDINAL_POSITION"
    );
    $st->execute([$tabla]);
    $pk = $st->fetchAll(PDO::FETCH_COLUMN);
    if ($pk === []) {
        fwrite(STDERR, "La tabla $tabla no tiene clave primaria; se omite.\n");
        continue;
    }

    $sql = 'SELECT * FROM `' . $tabla . '` ORDER BY `' . implode('`, `', $pk) . '`';
    $filas = $pdo->query($sql)->fetchAll();

    $contexto = hash_init('sha256');
    $hashesFila = [];
    $porUsuario = [];

    foreach ($filas as $fila) {
        $partes = [];
        foreach ($columnas as $columna) {
            $valor = $fila[$columna];
            if ($tabla === 'usuario' && $columna === 'hash_contrasena' && $valor !== null) {
                // Nunca se serializa el hash real: se usa su SHA-256.
                $valor = hash('sha256', $valor);
            }
            $partes[] = valor_canonico($valor === null ? null : (string) $valor);
        }
        $linea = implode('|', $partes);
        hash_update($contexto, $linea . "\n");
        $hashesFila[] = hash('sha256', $linea);

        if (in_array('id_usuario', $columnas, true)) {
            $id = (string) $fila['id_usuario'];
            $porUsuario[$id] = ($porUsuario[$id] ?? '') . $linea . "\n";
        }
    }

    $digestsUsuario = [];
    foreach ($porUsuario as $id => $flujo) {
        $digestsUsuario[$id] = hash('sha256', $flujo);
    }

    // Huella de esquema: SHOW CREATE TABLE sin AUTO_INCREMENT puntual.
    $crear = $pdo->query('SHOW CREATE TABLE `' . $tabla . '`')->fetch(PDO::FETCH_NUM)[1];
    $crear = preg_replace('/ AUTO_INCREMENT=\d+/', '', $crear);
    $crear = preg_replace('/\s+/', ' ', $crear);

    $manifiesto['tablas'][$tabla] = [
        'filas'              => count($filas),
        'digest_tabla'       => hash_final($contexto),
        'schema_digest'      => hash('sha256', trim($crear)),
        'digest_por_usuario' => $digestsUsuario,
    ];

    printf("%-18s filas=%-4d digest=%s\n", $tabla, count($filas),
        $manifiesto['tablas'][$tabla]['digest_tabla']);
}

file_put_contents($salida, json_encode($manifiesto, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));
fwrite(STDOUT, "\nManifiesto: $salida\n");
