class xp::misc {

  package {
    ['ntp', 'vlan', 'bridge-utils']:
      ensure => installed;
  }

  augeas {
    'sysctl/net.ipv4.ip_forward':
      context => '/files/etc/sysctl.conf',
      onlyif  => "get net.ipv4.ip_forward != '1'",
      changes => "set net.ipv4.ip_forward '1'",
      tag     => 'sysctl';
  }

  augeas {
    'sysctl/net.ipv4.conf.all.rp_filter':
      context => '/files/etc/sysctl.conf',
      onlyif  => "get net.ipv4.conf.all.rp_filter != '0'",
      changes => "set net.ipv4.conf.all.rp_filter '0'",
      tag     => 'sysctl';
  }

  augeas {
    'sysctl/net.ipv4.conf.default.rp_filter':
      context => '/files/etc/sysctl.conf',
      onlyif  => "get net.ipv4.conf.default.rp_filter != '0'",
      changes => "set net.ipv4.conf.default.rp_filter '0'",
      tag     => 'sysctl';
  }

  exec {
    'sysctl -p':
      path        => "/usr/bin:/usr/sbin:/bin:/sbin",
      refreshonly => true;
  }

  Augeas <| tag == 'sysctl' |> ~> Exec['sysctl -p']

}
