class xp::mysql {

  include '::mysql'

  file {
    '/etc/mysql/my.cnf':
      ensure => file,
      mode   => '0644',
      owner  => root,
      group  => root,
      source => 'puppet:///modules/xp/mysql/my.cnf';
  }

  Package['mysql-server'] -> File['/etc/mysql/my.cnf'] ~> Service['mysql']

}
