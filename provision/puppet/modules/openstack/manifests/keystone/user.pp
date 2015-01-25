define openstack::keystone::user (
  $email='admin@exemple.org',
  $pass='ADMIN'
) {

  exec {
    "keystone user-create --name=${name} --pass=\"${pass}\" --email=\"${email}\"":
      path   => "/usr/bin:/usr/sbin:/bin:/sbin",
      environment => [
        'OS_SERVICE_TOKEN=ADMIN',
        "OS_SERVICE_ENDPOINT=http://${ipaddress}:35357/v2.0"
      ],
      unless => "keystone user-get ${name}";
  }

}

define openstack::keystone::user_role (
  $user,
  $tenant,
  $role
) {

  exec {
    "keystone user-role-add --user=${user} --tenant=${tenant} --role=${role}":
      path   => "/usr/bin:/usr/sbin:/bin:/sbin",
      environment => [
        'OS_SERVICE_TOKEN=ADMIN',
        "OS_SERVICE_ENDPOINT=http://${ipaddress}:35357/v2.0"
      ],
      unless => "keystone user-role-list --user=${user} --tenant=${tenant} | grep ${role}";
  }

}
