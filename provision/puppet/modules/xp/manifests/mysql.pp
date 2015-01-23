class xp::mysql {

  package {
    ['mysql-server', 'python-mysqldb']:
      ensure => installed;
  }

  service {
    'mysql':
      ensure => running;
  }

  file {
    '/etc/mysql/my.cnf':
      ensure => file,
      mode   => '0644',
      owner  => root,
      group  => root,
      source => 'puppet:///modules/xp/mysql/my.cnf';
  }

  Package['mysql-server'] -> Service['mysql']
  File['/etc/mysql/my.cnf'] ~> Service['mysql']

}
