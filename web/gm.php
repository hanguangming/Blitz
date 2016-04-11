<?php
error_reporting(E_ALL);

function send_cmd($cmd) {
    $ip = '127.0.0.1';
    $port = $_GET['manage_port'];

    $socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
    if ($socket < 0) {
        echo "socket_create() failed: reason: " . socket_strerror($socket) . "<br>";
        return;
    }
    socket_set_block($socket);
    $result = socket_connect($socket, $ip, $port);
    if ($result === false) {
        echo "socket_connect() failed.\nReason: ($result) " . socket_strerror(socket_last_error($socket)) . "<br>";
        socket_close($socket);
        return;
    } 

    $len = strlen($cmd);
    $servlet = 589825;
    $seq = 1;
    $format = "I4a$len";
    $req = pack("$format", $len + 16, $servlet, 1, $len, $cmd);

    if(!socket_write($socket, $req, $len + 16)) {
        echo "socket_write() failed: reason: " . socket_strerror($socket) . "\n";
        socket_close($socket);
        return;
    }

    if ($rsp = socket_read($socket, 20, PHP_BINARY_READ)) {
        $pkg_head = unpack("i1len/i1servlet/i1seq/irc/istr_size", $rsp);
        if ($rsp = socket_read($socket, $pkg_head[str_size], PHP_BINARY_READ)) {
            $result = unpack("a$pkg_head[str_size]", $rsp);
        }
    }
    else {
        socket_close($socket);
        return;
    }
    socket_close($socket);
    return $result[1];
}

?>

<form action="">
    <input type="text" name="command" size="100%" value="<?php echo $_GET['command']?>"/>
    <input type="hidden" name="server_id" value="<?php echo $_GET['server_id']?>"/>
    <input type="hidden" name="host" value="<?php echo $_GET['host']?>"/>
    <input type="hidden" name="manage_port" value="<?php echo $_GET['manage_port']?>"/>
    <input type="submit"/>
</form>
<?php
echo send_cmd($_GET['command']);
?>

