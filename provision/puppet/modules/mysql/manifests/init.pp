class mysql {

  package {
    ['mysql-server', 'python-mysqldb']:
      ensure => installed;
  }

  service {
    'mysql':
      ensure => running;
  }

  Package['mysql-server'] -> Service['mysql']

}
