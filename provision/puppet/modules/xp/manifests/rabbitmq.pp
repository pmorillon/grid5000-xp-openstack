class xp::rabbitmq {

  package {
    'rabbitmq-server':
      ensure => installed;
  }

}
