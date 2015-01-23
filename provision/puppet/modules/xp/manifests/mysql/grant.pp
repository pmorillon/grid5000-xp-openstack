define xp::mysql::grant (
  $privileges,
  $database,
  $user,
  $password
) {

  exec {
    "Grant ${privileges} on ${database} for user ${user}":
      command => "/usr/bin/mysql --execute=\"GRANT ${privileges} ON ${database}.* TO '${user}'@'%' IDENTIFIED BY '${password}';\"",
      unless  => "/usr/bin/mysql --database mysql --raw -NBe \"SHOW GRANTS FOR 'keystone'@'%';\"";
  }

  Package['mysql-server'] -> Exec <| |>


}
