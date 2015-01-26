class xp::openstack::neutron {

  include 'xp::mysql'

  mysql::database {
    'neutron':
      ensure => present;
  }

  mysql::grant {
    'neutron':
      privileges => 'ALL PRIVILEGES',
      database   => 'neutron',
      user       => 'neutron',
      password   => 'neutron_dbpass';
  }

  Mysql::Database['neutron'] -> Mysql::Grant['neutron']

}
