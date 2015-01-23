class xp::rabbitmq {

  package {
    'rabbitmq-server':
      ensure => installed;
  }

  service {
    'rabbitmq-server':
      ensure => running;
  }

  exec {
    'change rabbitmq guest password':
      command     => 'rabbitmqctl change_password guest rabbit',
      path        => "/usr/bin:/usr/sbin:/bin",
      user        => root,
      group       => root,
      refreshonly => true;
  }

  Package[rabbitmq-server] -> Service['rabbitmq-server']
  Package[rabbitmq-server] ~> Exec['change rabbitmq guest password']

}
