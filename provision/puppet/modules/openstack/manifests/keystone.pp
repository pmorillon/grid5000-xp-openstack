class openstack::keystone {

  package {
    'keystone':
      ensure => installed;
  }

  service {
    'keystone':
      ensure => running;
  }

  Package['keystone'] -> Service['keystone']

}
