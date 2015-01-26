class xp::openstack::glance {

  include 'xp::mysql'
  include '::openstack::glance'

  mysql::database {
    'glance':
      ensure => present;
  }

  mysql::grant {
    'glance':
      privileges => 'ALL PRIVILEGES',
      database   => 'glance',
      user       => 'glance',
      password   => 'glance_dbpass';
  }

  Mysql::Database['glance'] -> Mysql::Grant['glance']

}
