<?php
$db_host = "localhost";
$db_user = "sgq";
$db_passwd = "sgq";
$db_database = "sgq";

$db_conn = mysql_connect($db_host, $db_user, $db_passwd) or die("connect failed " . mysql_error()); 
mysql_select_db($db_database, $db_conn);
?>

