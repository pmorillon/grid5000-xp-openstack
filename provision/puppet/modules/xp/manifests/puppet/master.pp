class xp::puppet::master {

  include 'xp::apache'

  File <| tag == 'setup' |> {
    ensure => file,
    mode   => '0644',
    owner  => root,
    group  => root
  }

  $agents       = hiera_array('puppet_agents')
  $version      = '3.7.3-1puppetlabs1'
  $puppetmaster = hiera('puppetmaster')

  package {
    ['puppetmaster-common', 'puppetmaster', 'puppetmaster-passenger']:
      ensure => $version;
  }

  file {
    '/etc/default/puppetmaster':
      tag    => 'setup',
      source => 'puppet:///modules/xp/puppet/master/puppetmaster.default';
    '/etc/puppet/puppet.conf':
      tag    => 'setup',
      source => 'puppet:///modules/xp/puppet/master/puppet.conf';
    '/etc/puppet/manifests/site.pp':
      tag     => 'setup',
      content => template('xp/puppet/master/site.pp.erb');
    '/etc/puppet/autosign.conf':
      tag     => 'setup',
      content => template('xp/puppet/master/autosign.conf.erb');
    '/etc/puppet/exports':
      ensure => directory,
      mode   => '0644',
      owner  => root,
      group  => root;
    '/etc/puppet/exports/xpfiles':
      ensure => directory,
      mode   => '0644',
      owner  => root,
      group  => root;
    '/etc/puppet/fileserver.conf':
      tag    => setup,
      source => 'puppet:///modules/xp/puppet/master/fileserver.conf';
  }

  service {
    'puppetmaster':
      ensure  => stopped,
      enable  => false;
  }

  Package['puppetmaster-common'] -> Package['puppetmaster'] -> Service['puppetmaster'] -> Package['puppetmaster-passenger']
  Package['puppetmaster-passenger'] -> File['/etc/puppet/puppet.conf'] ~> Service['apache2']
  Package['puppetmaster-passenger'] -> File['/etc/puppet/manifests/site.pp']

}
