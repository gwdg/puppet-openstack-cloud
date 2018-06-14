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
# == Class: cloud::identity
#
# Install Identity Server (Keystone)
#
# === Parameters:
#
# [*ks_admin_email*]
#   (optional) Email address of admin user in Keystone
#   Defaults to 'no-reply@keystone.openstack'
#
# [*ks_admin_password*]
#   (optional) Password of admin user in Keystone
#   Defaults to 'adminpassword'
#
# [*ks_admin_tenant*]
#   (optional) Admin tenant name in Keystone
#   Defaults to 'admin'
#
# [*cinder_password*]
#   (optional) Password used by Cinder to connect to Keystone API
#   Defaults to 'cinderpassword'
#
# [*ks_swift_dispersion_password*]
#   (optional) Password of the dispersion tenant, used for swift-dispersion-report
#   and swift-dispersion-populate tools.
#   Defaults to 'dispersion'
#
# [*api_eth*]
#   (optional) Which interface we bind the Keystone server.
#   Defaults to '127.0.0.1'
#
# [*token_expiration*]
#   (optional) Amount of time a token should remain valid (in seconds)
#   Defaults to '3600' (1 hour)
#
# [*cinder_enabled*]
#   (optional) Enable or not Cinder (Block Storage Service)
#   Defaults to true
#
# [*swift_enabled*]
#   (optional) Enable or not OpenStack Swift (Stockage as a Service)
#   Defaults to true
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
# [*keystone_master_name*]
#   Hostname of the keystone master node from which ssl certs are copied (needed 
#   for HA).
#
class cloud::identity (

  $identity_driver              = 'sql',
  $assignment_driver            = 'sql',

  $cinder_enabled               = true,
  $magnum_enabled               = false,
  $swift_enabled                = false,

  $ks_admin_email               = 'no-reply@keystone.openstack',
  $ks_admin_password            = 'adminpassword',
  $ks_admin_tenant              = 'admin',

  $ks_keystone_public_port      = undef,
  $ks_keystone_admin_port       = undef,
  $ssh_port                     = hiera('cloud::global::ssh_port'),

  $api_eth                      = '127.0.0.1',
  $firewall_settings            = {},

  # New stuff
  $keystone_master_name         = undef,
  $use_ldap                     = false,
  $ldap_backends                = {},
  $custom_policies              = {},

  $endpoints                    = undef,
){

  include ::keystone::db
  include ::mysql::client

  # Active mod status for monitoring of Apache
  include ::apache::mod::status

  class { '::keystone': }

  keystone_config {
    # Make sure identity / assignment is configured for sql in keystone.conf (ldap is done via domain specific configuration)
    'identity/driver':          value => $identity_driver;
    'assignment/driver':        value => $assignment_driver;
  }

  # Keystone LDAP
  if $use_ldap {
    create_resources('::keystone::ldap_backend', $ldap_backends)
  }


  # Keystone Endpoints + Users

  if $endpoints {
    create_resources('::cloud::identity::endpoint', $endpoints)
  }

  class { '::keystone::roles::admin':

    email        => $ks_admin_email,
    password     => $ks_admin_password,
    admin_tenant => $ks_admin_tenant,
  }

  class {'::keystone::endpoint': }

  # Configure keystone to use apache/wsgi
  class {'::keystone::wsgi::apache':

    servername  => $::fqdn,

    admin_port  => $ks_keystone_admin_port,
    public_port => $ks_keystone_public_port,

    # Use multiprocessing defaults
    workers     => 1,
    threads     => $::processorcount,

    ssl         => false
  }

  # Deploy ssh keys for keystone account to allow remote access via scp
  cloud::util::ssh_access { 'keystone':                                                                                                                                                                   
    home_dir          => '/var/lib/keystone',
    user              => 'keystone',                                                                                                                                                                      
    group             => 'keystone',
    public_key_file   => 'puppet:///modules/cloud/secrets/keystone_ssh_key.pub',
    private_key_file  => 'puppet:///modules/cloud/secrets/keystone_ssh_key',
    require           => Anchor['keystone::install::end'],
  }                                                                                                                                                                                                       

  # For keystone HA deployment all certs in /etc/keystone/ssl need to be copied from master node to slave node(s)  
  if $::fqdn == $keystone_master_name {

    # Restrict keystone account to just scp
    package { 'rssh': }

    exec { 'keystone-change-shell-to-rssh':
      command   => "/usr/bin/chsh -s /usr/bin/rssh keystone",
      require   => [ Package['rssh'], Package['keystone'] ],
    }

    exec { 'enable-rssh-scp': 
      command   => "/bin/sed -i 's/#allowscp/allowscp/g' /etc/rssh.conf",
      require   => Package['rssh'],
    }

  } else {

    # Copy files
    #exec { 'keystone-copy-ssl-certs':
    #  command   => "/usr/bin/scp -P $ssh_port -r -o StrictHostKeyChecking=no keystone@${keystone_master_name}:/etc/keystone/ssl /etc/keystone/",
    #  creates   => '/etc/keystone/ssl/synced_from_master',
    #  user      => 'keystone',
    #  require   => [ Cloud::Util::Ssh_access['keystone'], Class['keystone'] ],
    #  notify    => Service['httpd']
    #}

    # Copy fernet keys from master node to slave node(s)
    # Ensure /etc/keystone/fernet-keys/ directory is present and empty
    file { '/etc/keystone/fernet-keys/':
      ensure => directory,
      recurse => true,
      purge => true,
      force => true,
      owner  => 'keystone',
      group  => 'keystone',
      mode   => '0600',
      require => Anchor['keystone::install::end'],
    }
    # Copy Fernet Keys from master node
    exec { 'keystone-copy-fernet-keys':
      command   => "/usr/bin/scp -P $ssh_port -r -o StrictHostKeyChecking=no keystone@${keystone_master_name}:/etc/keystone/fernet-keys /etc/keystone/",
      creates   => '/etc/keystone/fernet-keys/0',
      user      => 'keystone',
      before    => Anchor['keystone::config::begin'],
      require   => [Cloud::Util::Ssh_access['keystone'], File['/etc/keystone/fernet-keys/']],
      notify    => Service['httpd']
    }

  }

  if $swift_enabled {
    class {'::swift::keystone::dispersion': }
  }                                                            

  if $cinder_enabled {
    class { '::cinder::keystone::auth': }
  }

  class { '::cloud::orchestration::domain': }

  if $magnum_enabled {
    class { '::cloud::container::domain': }
  }

  # Purge expored tokens every days at midnight
  class { '::keystone::cron::token_flush': }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow keystone access':
      port   => $ks_keystone_public_port,
      extras => $firewall_settings,
    }
    cloud::firewall::rule{ '100 allow keystone admin access':
      port   => $ks_keystone_admin_port,
      extras => $firewall_settings,
    }
  }

  @@haproxy::balancermember{"${::fqdn}-keystone_api":
    listening_service => 'keystone_api',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_keystone_public_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  @@haproxy::balancermember{"${::fqdn}-keystone_api_admin":
    listening_service => 'keystone_api_admin',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_keystone_admin_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  class { '::keystone::policy':
    policies => $custom_policies
  }
}
