define openstack::keystone::tenant (
  $description
) {

  exec {
    "keystone tenant-create --name=${name} --description=\"${description}\"":
      path   => "/usr/bin:/usr/sbin:/bin:/sbin",
      environment => [
        'OS_SERVICE_TOKEN=ADMIN',
        "OS_SERVICE_ENDPOINT=http://${ipaddress}:35357/v2.0"
      ],
      unless => "keystone tenant-get ${name}";
  }

}
