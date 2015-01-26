class xp::roles::controller {

  include 'xp::rabbitmq'
  include 'xp::mysql'
  include 'xp::misc'
  include 'xp::openstack::keystone'
  include 'xp::openstack::glance'
  include 'xp::openstack::nova'
  include 'xp::openstack::neutron'
  include 'xp::openstack::cinder'

}
