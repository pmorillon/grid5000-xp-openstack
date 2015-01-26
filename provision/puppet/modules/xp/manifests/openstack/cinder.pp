class xp::openstack::cinder {

  include 'xp::mysql'

  mysql::database {
    'cinder':
      ensure => present;
  }

  mysql::grant {
    'cinder':
      privileges => 'ALL PRIVILEGES',
      database   => 'cinder',
      user       => 'cinder',
      password   => 'cinder_dbpass';
  }

  Mysql::Database['cinder'] -> Mysql::Grant['cinder']

}
