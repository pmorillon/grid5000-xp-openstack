class xp::openstack::keystone {

  include 'xp::mysql'
  include '::openstack::keystone'

  mysql::database {
    'keystone':
      ensure => present;
  }

  mysql::grant {
    'keystone':
      privileges => 'ALL PRIVILEGES',
      database   => 'keystone',
      user       => 'keystone',
      password   => 'keystone_dbpass';
  }

  file {
    '/etc/keystone/keystone.conf':
      ensure => file,
      mode   => '0644',
      owner  => root,
      group  => root,
      source => 'puppet:///modules/xp/openstack/keystone/keystone.conf';
  }

  # Sync the keystone database
  exec {
    'keystone-manage db_sync':
      path   => "/usr/bin:/usr/sbin:/bin:/sbin",
      unless => "/usr/bin/mysql --database keystone --raw -NBe \"SHOW TABLES;\" | grep user";
  }

  # Populate the keystone
  openstack::keystone::tenant {
    'admin':
      description => 'Admin tenant';
    'service':
      description => 'Service tenant';
  }

  openstack::keystone::user {
    'admin':
      email => 'admin@exemple.org',
      pass  => 'ADMIN';
  }

  openstack::keystone::role {
    'admin':
  }

  openstack::keystone::user_role {
    'admin admin':
      user    => admin,
      tenant  => admin,
      role    => admin,
      require => [
        Openstack::Keystone::Tenant['admin'],
        Openstack::Keystone::User['admin'],
        Openstack::Keystone::Role['admin']
      ];
  }

  Mysql::Database['keystone'] -> Mysql::Grant['keystone'] -> Package['keystone']

  Package['keystone'] -> File['/etc/keystone/keystone.conf'] ~> Service['keystone']
  File['/etc/keystone/keystone.conf'] -> Exec['keystone-manage db_sync']
  Service['keystone'] -> Exec['keystone-manage db_sync']
  Mysql::Grant['keystone'] -> Exec['keystone-manage db_sync']

  Exec['keystone-manage db_sync'] -> Openstack::Keystone::Tenant <||>
  Exec['keystone-manage db_sync'] -> Openstack::Keystone::User <||>
  Exec['keystone-manage db_sync'] -> Openstack::Keystone::Role <||>

}
