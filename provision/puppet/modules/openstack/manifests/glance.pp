class openstack::glance {

  package {
    'glance':
      ensure => installed;
  }

  service {
    'glance-api':
      ensure => running;
    'glance-registry':
      ensure => running;
  }

  Package['glance'] -> Service <||>

}
