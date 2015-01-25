define openstack::keystone::role () {

  exec {
    "keystone role-create --name=${name}":
      path   => "/usr/bin:/usr/sbin:/bin:/sbin",
      environment => [
        'OS_SERVICE_TOKEN=ADMIN',
        "OS_SERVICE_ENDPOINT=http://${ipaddress}:35357/v2.0"
      ],
      unless => "keystone role-get ${name}";
  }

}
