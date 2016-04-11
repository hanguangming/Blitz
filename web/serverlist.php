<?php

include "db.php";

$result = mysql_query("select id, name, host, port, manage_port, state, r from server", $db_conn); 

echo "{\n";
while ($row = mysql_fetch_array($result)) {
    echo "{id='$row[0]', name='$row[1]', ip='$row[2]', port='$row[3]', state='$row[5]', r='$row[6]'},\n";
}
echo "}\n";
?>

