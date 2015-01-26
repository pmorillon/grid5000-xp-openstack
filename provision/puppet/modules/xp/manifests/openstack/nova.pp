class xp::openstack::nova {

  include 'xp::mysql'

  mysql::database {
    'nova':
      ensure => present;
  }

  mysql::grant {
    'nova':
      privileges => 'ALL PRIVILEGES',
      database   => 'nova',
      user       => 'nova',
      password   => 'nova_dbpass';
  }

  Mysql::Database['nova'] -> Mysql::Grant['nova']

}
