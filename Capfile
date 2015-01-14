# Capfile
## -*- mode: ruby -*-
## vi: set ft=ruby :

require "xp5k"
require "yaml"


# Load ./xp.conf file
#
XP5K::Config.load


# Initialize experiment
#
@xp = XP5K::XP.new(:logger => logger)
def xp; @xp; end


# Defaults configuration
#
XP5K::Config[:walltime]   ||= '1:00:00'
XP5K::Config[:user]       ||= ENV['USER']
XP5K::Config[:computes]   ||= 1


# Constants
#
PUPPET_VERSION = '3.7.3'
SSH_CONFIGFILE_OPT = XP5K::Config[:ssh_config].nil? ? "" : " -F " + XP5K::Config[:ssh_config]
SSH_CMD = "ssh -o ConnectTimeout=10" + SSH_CONFIGFILE_OPT


# Define vars used for file synchronization between local repo and the puppet master
#
sync_path = File.expand_path(File.join(Dir.pwd, 'provision'))
synced = false


# Define a OAR job
#
resources = []
resources << %{{type='kavlan'}/vlan=1}
resources << %{nodes=3}
resources << %{walltime=#{XP5K::Config[:walltime]}}

roles = []
roles << XP5K::Role.new({ :name => 'puppet', :size => 1 })
roles << XP5K::Role.new({ :name => 'controller', :size => 1 })
roles << XP5K::Role.new({ :name => 'computes', :size => 1 })

job_description = {
  :resources => resources.join(","),
  :site      => XP5K::Config['site'],
  :queue     => XP5K::Config[:queue] || 'default',
  :types     => ["deploy"],
  :name      => "xp5k_openstack",
  :roles     => roles,
  :command   => "sleep 186400"
}

job_description[:reservation] = XP5K::Config[:reservation] if not XP5K::Config[:reservation].nil?
xp.define_job(job_description)


# Define deployments
#
xp.define_deployment({
  :site          => XP5K::Config['site'],
  :environment   => "wheezy-x64-base",
  :roles         => %w{ puppet },
  :key           => File.read(XP5K::Config[:public_key]),
  :vlan_from_job => 'xp5k_openstack',
  :notifications => ["xmpp:#{XP5K::Config[:user]}@jabber.grid5000.fr"]
})

xp.define_deployment({
  :site          => XP5K::Config['site'],
  :environment   => "http://public.rennes.grid5000.fr/~pmorillo/ubuntu-x64-14.10.env",
  :roles         => %w{ controller computes },
  :key           => File.read(XP5K::Config[:public_key]),
  :vlan_from_job => 'xp5k_openstack',
  :notifications => ["xmpp:#{XP5K::Config[:user]}@jabber.grid5000.fr"]
})


# Configure SSH for capistrano
#
set :gateway, XP5K::Config[:gateway] if XP5K::Config[:gateway]
set :ssh_config, XP5K::Config[:ssh_config] if XP5K::Config[:ssh_config]


# Define roles
#
role :puppet do
  kavlanHostsList(xp.role_with_name("puppet").servers, vlansForJobName('xp5k_openstack').first)
end

role :controller do
  kavlanHostsList(xp.role_with_name("controller").servers, vlansForJobName('xp5k_openstack').first)
end

role :computes do
  kavlanHostsList(xp.role_with_name("computes").servers, vlansForJobName('xp5k_openstack').first)
end

role :empty do
  []
end


# Task for commands
#
desc "run command on computes nodes (need CMD and ROLES, computes by default)"
task :cmd, :roles => :empty do
  raise "Need CMD environment variable" unless ENV['CMD']
  raise "Need ROLES environment variable" unless ENV['ROLES']
  set :user, 'root'
  run ENV['CMD']
end


# Tasks for OAR job management
#
namespace :oar do
  desc "Submit OAR jobs"
  task :submit do
    xp.submit
    xp.wait_for_jobs
  end

  desc "Clean all running OAR jobs"
  task :clean do
    logger.debug "Clean all Grid'5000 running jobs..."
    xp.clean
  end

  desc "OAR jobs status"
  task :status do
    xp.status
  end
end


# Tasks for deployments management
#
namespace :kadeploy do
  desc "Submit kadeploy deployments"
  task :submit do
    xp.deploy
  end
end

# Tasks for Puppet provisioning
#
namespace :provision do
  desc "Install puppet agent"
  task :setup_agent, :roles => :puppet do
    set :user, "root"
    run 'apt-get update && apt-get -y install curl wget'
    run "http_proxy=http://proxy:3128 https_proxy=http://proxy:3128 wget -O /tmp/puppet_install.sh https://raw.githubusercontent.com/pmorillon/puppet-puppet/master/extras/bootstrap/puppet_install.sh"
    run "http_proxy=http://proxy:3128 https_proxy=http://proxy:3128 PUPPET_VERSION=#{PUPPET_VERSION} sh /tmp/puppet_install.sh"
  end

  desc "Install Puppet master"
  task :setup_server, :roles => :puppet do
    set :user, "root"
    run "apt-get -y install puppetmaster=#{PUPPET_VERSION}-1puppetlabs1 puppetmaster-common=#{PUPPET_VERSION}-1puppetlabs1"
  end

  #before 'provision:frontend', 'provision:upload_modules'

  #desc "Provision frontend"
  #task :frontend, :roles => :puppet do
    #set :user, "root"
    #upload "provision/hiera/hiera.yaml", "/etc/puppet/hiera.yaml"
    #run "http_proxy=http://proxy:3128 https_proxy=http://proxy:3128 puppet apply --modulepath=/srv/provision/puppet/modules -e 'include xp::frontend'"
  #end

  #before 'provision:all', 'provision:upload_modules'

  #desc 'Provision all puppet agents'
  #task :all, :roles => [:controller, :computes], :on_error => :continue do
    #set :user, 'root'
    #run "http_proxy=http://proxy:3128 https_proxy=http://proxy:3128 puppet agent -t --server #{xp.role_with_name("puppet").servers.first}"
  #end

  #desc "Upload modules on Puppet master"
  #task :upload_modules do
    #unless synced
      #%x{rsync -e '#{SSH_CMD}' -rl --delete --exclude '.git*' #{sync_path} root@#{xp.role_with_name("puppet").servers.first}:/srv}
      #synced = true
    #end
  #end

end


# Get Vlans for a job
#
def vlansForJobName(jobname)
  xp.job_with_name(jobname)['resources_by_type']['vlans']
end


# Convert hostname list to kavlan fqdn
#
def kavlanHostsList(list, vlanid)
  list.map { |node| node.gsub(/-(\d+)/, '-\1-kavlan-' + vlanid.to_s) }
end
