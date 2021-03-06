#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: cloud
#
# Installs the system requirements
#
# === Parameters:
#
# [*root_password*]
#  (optional) Unix root password
#  Defaults to 'root'
#
# [*dns_ips*]
#  (optional) Hostname or IP of the Domain Name Server (dns) used
#  Should by an array.
#  Defaults to google public dns ['8.8.8.8', '8.8.4.4']
#
# [*site_domain*]
#  (optional) Domain name (used for search and domain fields
#  of resolv.conf configuration file
#  Defaults to 'mydomain'
#
# [*motd_title*]
#  (optional) A string used in the top of the server's motd
#  Defaults to 'eNovance IT Operations'
#
# [*selinux_mode*]
#   (optional) SELinux mode the system should be in
#   Defaults to 'permissive'
#   Possible values : disabled, permissive, enforcing
#
# [*selinux_directory*]
#   (optional) Path where to find the SELinux modules
#   Defaults to '/usr/share/selinux'
#
# [*selinux_booleans*]
#   (optional) Set of booleans to persistently enables
#   SELinux booleans are the one getsebool -a returns
#   Defaults []
#   Example: ['rsync_full_access', 'haproxy_connect_any']
#
# [*selinux_modules*]
#   (optional) Set of modules to load on the system
#   Defaults []
#   Example: ['module1', 'module2']
#   Note: Those module should be in the $directory path
#
# [*limits*]
#   (optional) Set of limits to set in /etc/security/limits.d/
#   Defaults {}
#   Example:
#     {
#       'mysql_nofile' => {
#          'ensure'     => 'present',
#          'user'       => 'mysql',
#          'limit_type' => 'nofile',
#          'both'       => '16384',
#       },
#     }
#
# [*sysctl*]
#   (optional) Set of sysctl values to set.
#   Defaults {}
#   Example:
#     {
#       'net.ipv4.ip_forward' => {
#          'value' => '1',
#       },
#       'net.ipv6.conf.all.forwarding => {
#          'value' => '1',
#       },
#     }
#
# [*manage_firewall*]
#  (optional) Completely enable or disable firewall settings
#  (false means disabled, and true means enabled)
#  Defaults to false
#
# [*firewall_rules*]
#   (optional) Allow to add custom firewall rules
#   Should be an hash.
#   Default to {}
#
# [*purge_firewall_rules*]
#   (optional) Boolean, purge all firewall resources
#   Defaults to false
#
# [*firewall_pre_extras*]
#   (optional) Allow to add custom parameters to firewall rules (pre stage)
#   Should be an hash.
#   Default to {}
#
# [*firewall_post_extras*]
#   (optional) Allow to add custom parameters to firewall rules (post stage)
#   Should be an hash.
#   Default to {}
#
class cloud(
  $root_password            = 'root',
  $dns_ips                  = ['8.8.8.8', '8.8.4.4'],
  $site_domain              = 'mydomain',
  $motd_title               = 'eNovance IT Operations',
  $selinux_mode             = 'permissive',
  $selinux_directory        = '/usr/share/selinux',
  $selinux_booleans         = [],
  $selinux_modules          = [],
  $limits                   = {},
  $sysctl                   = {},
  $manage_firewall          = false,
  $firewall_rules           = {},
  $purge_firewall_rules     = false,
  $firewall_pre_extras      = {},
  $firewall_post_extras     = {},

  # Additional stuff
  $manage_root_password     = false,
  $production               = false,
  $ntp_servers              = [],
  $ntp_interfaces_ignore    = [],
  $ntp_interfaces           = [],
  $lldpd_interfaces         = [],
  $groups                   = {},
  $users                    = {},

  $syslog_server            = undef,
  $syslog_port              = undef,
) {

  include ::stdlib

  # Apt setup
#  Apt::Ppa <| |> -> Package <| title != 'software-properties-common' |>

  Package {
    provider        => 'apt',    
    install_options => ['--no-install-recommends'],
  }

  Apt::Source <| |> -> Exec['apt_update'] -> Package <| |>

  # Activate Force-Yes "true", so that downgrades from aptly work in puppet
  file { '/etc/apt/apt.conf.d/99aptly':
    content => 'APT::Get::Force-Yes "true";',
  }
  File['/etc/apt/apt.conf.d/99aptly'] -> Package <| |>

  class {'::apt':

    # For apt-cacher-ng
#   proxy_host => 'puppetmaster.cloud.gwdg.de',
#   proxy_port => '3142',

    # Purge all repos not managed by puppet
    purge => { 'sources.list' => true , 'sources.list.d' => true },
  }

  apt::conf { 'progressbar':
    priority => '99',
    content  => 'Dpkg::Progress-Fancy "1";',
  }

  apt::conf { 'norecommends':
    priority => '00',
    content  => "Apt::Install-Recommends 0;\nApt::AutoRemove::InstallRecommends 1;\n",
  }

  # Create users / groups whose uids / gids need to be in sync on different systems
#  Group <| |>   -> User <| |>
#  User <| |>    -> Package <| |>

  create_resources(group,   $groups)
  create_resources(user,    $users)

  if ! ($::osfamily in [ 'Debian' ]) {
    fail("OS family unsuppored yet (${::osfamily}), module puppet-openstack-cloud only support Debian")
  }

  # motd
  file { '/etc/motd':
      ensure  => file,
      mode    => '0644',
      content => template('cloud/motd.txt'),
# ${motd_title} # This node is under the control of Puppet ${::puppetversion} #
  }

  # DNS (does not work with resolvconf on ubuntu)
#  class { 'dnsclient':
#    nameservers => $dns_ips,
#    domain      => $site_domain
#  }

  # SUDO (don't use for now, kills vagrant)
#  include ::sudo
#  include ::sudo::configs
  
  include ::telegraf

  # NTP (do not install for containers)
  if ! ($::virtual == 'lxc')  {
    class { '::ntp':
      servers     => $ntp_servers,
      restrict    => ['127.0.0.1'],
      interfaces_ignore  => $ntp_interfaces_ignore,
      interfaces => $ntp_interfaces,   
    }
  }

  if ! ($::virtual == 'lxc')  {
   class { '::lldpd':
     interfaces => $lldpd_interfaces,    
   }
 }

  # Security Limits
  include ::limits
  create_resources('::limits::limits', $limits)

  # Some Ubuntu specific stuff
#  if $::operatingsystem == 'Ubuntu' {

    # Add cloud archive for Juno
#    apt::ppa { 'cloud-archive:juno': }

#  }

  # sysctl values
  include ::sysctl::base
  create_resources('::sysctl::value', $sysctl)

  # SELinux
#  if $::osfamily == 'RedHat' {
#    class {'::cloud::selinux' :
#      mode      => $selinux_mode,
#      booleans  => $selinux_booleans,
#      modules   => $selinux_modules,
#      directory => $selinux_directory,
#      stage     => 'setup',
#    }
#  }

  # Strong root password for all servers
  if $manage_root_password {
    user { 'root':
      ensure   => 'present',
      gid      => '0',
      password => $root_password,
      uid      => '0',
    }
  }

  $cron_service_name = $::osfamily ? {
    default  => 'cron',
  }

  service { 'cron':
    ensure => running,
    name   => $cron_service_name,
    enable => true
  }

  if $manage_firewall {

    # Only purges IPv4 rules
    if $purge_firewall_rules {
      resources { 'firewall':
        purge => true
      }
    }

    # anyone can add your own rules
    # example with Hiera:
    #
    # cloud::firewall::rules:
    #   '300 allow custom application 1':
    #     port: 999
    #     proto: udp
    #     action: accept
    #   '301 allow custom application 2':
    #     port: 8081
    #     proto: tcp
    #     action: accept
    #
    create_resources('::cloud::firewall::rule', $firewall_rules)

    ensure_resource('class', 'cloud::firewall::pre', {
      'firewall_settings' => $firewall_pre_extras,
      'stage'             => 'setup',
    })

    ensure_resource('class', 'cloud::firewall::post', {
      'stage'             => 'runtime',
      'firewall_settings' => $firewall_post_extras,
    })
  }

  exec { 'restart_rsyslogd':
    command     => 'service rsyslog restart',
    path        => [ '/usr/sbin', '/sbin', '/usr/bin/', '/bin', ],
    refreshonly => true,
  } 

  if $syslog_server {

    #*.* @@$IP_PREFIX.1.3:514 > /etc/rsyslog.d/10-logstash.conf
    file { '/etc/rsyslog.d/10-logstash.conf':
      ensure => file,
      content => "*.* @@${syslog_server}:${syslog_port}",
      owner => root,
      group => root,
      mode => '0644',
      notify => Exec['restart_rsyslogd']
    }
  }
}
