<?php

include "db.php";

$result = mysql_query("select id, name, host, port, manage_port, state from server", $db_conn); 

while ($row = mysql_fetch_array($result)) {
?>


<a href="gm.php?server_id=<?php echo $row[0]; ?>&host=<?php echo $row[2]; ?>&manage_port=<?php echo $row[4]; ?>"> <?php echo $row[1]; ?> </a><br>

<?php
}
?>

