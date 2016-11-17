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
# [*identity_roles_addons*]
#   (optional) Extra keystone roles to create
#   Defaults to ['SwiftOperator', 'ResellerAdmin']
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
# [*ks_admin_token*]
#   (required) Admin token used by Keystone.
#
# [*trove_password*]
#   (optional) Password used by Trove to connect to Keystone API
#   Defaults to 'trovepassword'
#
# [*ceilometer_password*]
#   (optional) Password used by Ceilometer to connect to Keystone API
#   Defaults to 'ceilometerpassword'
#
# [*swift_password*]
#   (optional) Password used by Swift to connect to Keystone API
#   Defaults to 'swiftpassword'
#
# [*nova_password*]
#   (optional) Password used by Nova to connect to Keystone API
#   Defaults to 'novapassword'
#
# [*neutron_password*]
#   (optional) Password used by Neutron to connect to Keystone API
#   Defaults to 'neutronpassword'
#
# [*heat_password*]
#   (optional) Password used by Heat to connect to Keystone API
#   Defaults to 'heatpassword'
#
# [*magnum_password*]
#   (optional) Password used by Magnum to connect to Keystone API
#   Defaults to 'magnumpassword'
#
# [*glance_password*]
#   (optional) Password used by Glance to connect to Keystone API
#   Defaults to 'glancepassword'
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
# [*region*]
#   (optional) OpenStack Region Name
#   Defaults to 'RegionOne'
#
# [*token_driver*]
#   (optional) Driver to store tokens
#   Defaults to 'keystone.token.persistence.backends.sql.Token'
#
# [*token_expiration*]
#   (optional) Amount of time a token should remain valid (in seconds)
#   Defaults to '3600' (1 hour)
#
# [*cinder_enabled*]
#   (optional) Enable or not Cinder (Block Storage Service)
#   Defaults to true
#
# [*trove_enabled*]
#   (optional) Enable or not Trove (Database as a Service)
#   Experimental feature.
#   Defaults to false
#
# [*swift_enabled*]
#   (optional) Enable or not OpenStack Swift (Stockage as a Service)
#   Defaults to true
#
# [*ks_token_expiration*]
#   (optional) Amount of time a token should remain valid (seconds).
#   Defaults to 3600 (1 hour).
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

  $token_driver                 = 'sql',
  $token_provider               = 'uuid',

  $identity_driver              = 'sql',
  $assignment_driver            = 'sql',

  $cinder_enabled               = true,
  $trove_enabled                = false,
  $magnum_enabled               = false,
  $swift_enabled                = false,

  $identity_roles_addons        = ['SwiftOperator', 'ResellerAdmin'],

  $ks_admin_email               = 'no-reply@keystone.openstack',
  $ks_admin_password            = 'adminpassword',
  $ks_admin_tenant              = 'admin',
  $ks_admin_token               = undef,

  $ceilometer_public_url        = undef,
  $ceilometer_internal_url      = undef,
  $ceilometer_admin_url         = undef,

  $ceilometer_password          = 'ceilometerpassword',

  $aodh_public_url              = undef,
  $aodh_internal_url            = undef,
  $aodh_admin_url               = undef,

  $aodh_password                = 'aodhpassword',

  $gnocchi_public_url           = undef,
  $gnocchi_internal_url         = undef,
  $gnocchi_admin_url            = undef,

  $gnocchi_password             = 'gnocchipassword',

  $cinder_v1_public_url         = undef,
  $cinder_v1_internal_url       = undef,
  $cinder_v1_admin_url          = undef,

  $cinder_v2_public_url         = undef,
  $cinder_v2_internal_url       = undef,
  $cinder_v2_admin_url          = undef,

  $cinder_v3_public_url         = undef,
  $cinder_v3_internal_url       = undef,
  $cinder_v3_admin_url          = undef,

  $cinder_password              = 'cinderpassword',

  $glance_public_url            = undef,
  $glance_internal_url          = undef,
  $glance_admin_url             = undef,

  $glance_password              = 'glancepassword',

  $heat_public_url              = undef,
  $heat_internal_url            = undef,
  $heat_admin_url               = undef,

  $heat_cfn_public_url          = undef,
  $heat_cfn_internal_url        = undef,
  $heat_cfn_admin_url           = undef,

  $heat_password                = 'heatpassword',

  $keystone_public_url          = undef,
  $keystone_internal_url        = undef,
  $keystone_admin_url           = undef,

  $ks_keystone_public_port      = undef,
  $ks_keystone_admin_port       = undef,
  $ssh_port                     = hiera('cloud::global::ssh_port'),

  $neutron_public_url           = undef,
  $neutron_internal_url         = undef,
  $neutron_admin_url            = undef,

  $neutron_password             = 'neutronpassword',

  $nova_v2_public_url           = undef,
  $nova_v2_internal_url         = undef,
  $nova_v2_admin_url            = undef,

  $nova_v3_public_url           = undef,
  $nova_v3_internal_url         = undef,
  $nova_v3_admin_url            = undef,

  $nova_password                = 'novapassword',

  $swift_public_url             = undef,
  $swift_internal_url           = undef,
  $swift_admin_url              = undef,

  $ks_swift_dispersion_password = 'dispersion',
  $swift_password               = 'swiftpassword',

  $trove_public_url             = undef,
  $trove_internal_url           = undef,
  $trove_admin_url              = undef,

  $trove_password               = 'trovepassword',

  $magnum_public_url            = undef,
  $magnum_internal_url          = undef,
  $magnum_admin_url             = undef,

  $magnum_password              = 'magnumpassword',

  $api_eth                      = '127.0.0.1',
  $region                       = 'RegionOne',
  $ks_token_expiration          = 3600,
  $firewall_settings            = {},

  # New stuff
  $keystone_master_name         = undef,
  $use_ldap                     = false,
  $ldap_backends                = {},
){

  include ::keystone::db
  include ::mysql::client

  if $token_provider == 'fernet' and $::fqdn == $keystone_master_name {

    $enable_fernet_setup = true
  } else {

    $enable_fernet_setup = false
  }

  class { '::keystone':
    enabled               => true,
    admin_token           => $ks_admin_token,

    service_name          => 'httpd',
    manage_policyrcd      => 'true',

    token_provider        => $token_provider,
    token_driver          => $token_driver,
    token_expiration      => $ks_token_expiration,

    public_bind_host      => $api_eth,
    admin_bind_host       => $api_eth,

    admin_endpoint        => $keystone_admin_url,
    public_endpoint       => $keystone_public_url,

    using_domain_config   => true,

    sync_db               => true,

    enable_fernet_setup   => $enable_fernet_setup,
  }

  keystone_config {
    # Make sure identity / assignment is configured for sql in keystone.conf (ldap is done via domain specific configuration)
    'identity/driver':          value => $identity_driver;
    'assignment/driver':        value => $assignment_driver;
  }

  # Keystone LDAP
  if $use_ldap {

    # Create domain for LDAP users ('GWDG')
    ensure_resource('keystone_domain', 'GWDG', {
      'ensure'  => 'present',
      'enabled' => true,
    })

    create_resources('::keystone::ldap_backend', $ldap_backends)
  }


  # Keystone Endpoints + Users

  class { '::keystone::roles::admin':

    email        => $ks_admin_email,
    password     => $ks_admin_password,
    admin_tenant => $ks_admin_tenant,
  }

#  keystone_role { $identity_roles_addons: ensure => present }

  class {'::keystone::endpoint':

    public_url   => $keystone_public_url,
    internal_url => $keystone_internal_url,
    admin_url    => $keystone_admin_url,

    region       => $region,
  }

  # Configure keystone to use apache/wsgi
#  include cloud::util::apache_common
  class {'::keystone::wsgi::apache':

    servername  => $::fqdn,

    admin_port  => $ks_keystone_admin_port,
    public_port => $ks_keystone_public_port,

    # Use multiprocessing defaults
    workers     => 1,
    threads     => $::processorcount,

    ssl         => false
  }

  if $swift_enabled {
    class {'::swift::keystone::auth':

      public_url        => $swift_public_url,
      internal_url      => $swift_internal_url,
      admin_url         => $swift_admin_url,

      password          => $swift_password,
      region            => $region
    }

    class {'::swift::keystone::dispersion':
      auth_pass         => $ks_swift_dispersion_password
    }
  }

  # Deploy ssh keys for keystone account to allow remote access via scp
  cloud::util::ssh_access { 'keystone':                                                                                                                                                                   
    home_dir          => '/var/lib/keystone',
    user              => 'keystone',                                                                                                                                                                      
    group             => 'keystone',
    public_key_file   => 'puppet:///modules/cloud/secrets/keystone_ssh_key.pub',
    private_key_file  => 'puppet:///modules/cloud/secrets/keystone_ssh_key',
    require           => Package['keystone'],
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
    exec { 'keystone-copy-ssl-certs':
      command   => "/usr/bin/scp -P $ssh_port -r -o StrictHostKeyChecking=no keystone@${keystone_master_name}:/etc/keystone/ssl /etc/keystone/",
      creates   => '/etc/keystone/ssl/synced_from_master',
      user      => 'keystone',
      require   => Cloud::Util::Ssh_access['keystone'],
      notify    => Service['httpd']
    }

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
    }
    # Copy Fernet Keys from master node
    exec { 'keystone-copy-fernet-keys':
      command   => "/usr/bin/scp -P $ssh_port -r -o StrictHostKeyChecking=no keystone@${keystone_master_name}:/etc/keystone/fernet-keys /etc/keystone/",
      creates   => '/etc/keystone/fernet-keys/0',
      user      => 'keystone',
      require   => [Cloud::Util::Ssh_access['keystone'], File['/etc/keystone/fernet-keys/']],
      notify    => Service['httpd']
    }

  }

  class {'::ceilometer::keystone::auth':

    public_url          => $ceilometer_public_url,
    internal_url        => $ceilometer_internal_url,
    admin_url           => $ceilometer_admin_url,

    region              => $region,
    password            => $ceilometer_password
  }


  class { '::aodh::keystone::auth':
    
    public_url          => $aodh_public_url,
    internal_url        => $aodh_internal_url,
    admin_url           => $aodh_admin_url,

    region              => $region,
    password            => $aodh_password
  }

  class { '::gnocchi::keystone::auth':

    public_url          => $gnocchi_public_url,
    internal_url        => $gnocchi_internal_url,
    admin_url           => $gnocchi_admin_url,

    region              => $region,
    password            => $gnocchi_password,
  }                                                                                                                                                                                                        

  class { '::nova::keystone::auth':

    public_url          => $nova_v2_public_url,
    internal_url        => $nova_v2_internal_url,
    admin_url           => $nova_v2_admin_url,

    public_url_v3       => $nova_v3_public_url,
    internal_url_v3     => $nova_v3_internal_url,
    admin_url_v3        => $nova_v3_admin_url,

    region              => $region,
    password            => $nova_password
  }                                                                                                                                                                                                         

  class { '::neutron::keystone::auth':

    public_url          => $neutron_public_url,
    internal_url        => $neutron_internal_url,
    admin_url           => $neutron_admin_url,

    region              => $region,
    password            => $neutron_password
  }

  if $cinder_enabled {
    class { '::cinder::keystone::auth':

      public_url        => $cinder_v1_public_url,
      internal_url      => $cinder_v1_internal_url,
      admin_url         => $cinder_v1_admin_url,

      public_url_v2     => $cinder_v2_public_url,
      internal_url_v2   => $cinder_v2_internal_url,
      admin_url_v2      => $cinder_v2_admin_url,

      public_url_v3     => $cinder_v3_public_url,
      internal_url_v3   => $cinder_v3_internal_url,
      admin_url_v3      => $cinder_v3_admin_url,

      region            => $region,
      password          => $cinder_password
    }
  }

  class { '::glance::keystone::auth':

    public_url          => $glance_public_url,
    internal_url        => $glance_internal_url,
    admin_url           => $glance_admin_url,

    region              => $region,
    password            => $glance_password
  }

  class { '::heat::keystone::auth':

    public_url          => $heat_public_url,                                                                                                                                                                
    internal_url        => $heat_internal_url,
    admin_url           => $heat_admin_url,                                                                                                                                                                 

    region              => $region,
    password            => $heat_password,    

    configure_delegated_roles => true
  }

  class { '::cloud::orchestration::domain': }

  class { '::heat::keystone::auth_cfn':

    public_url          => $heat_cfn_public_url,
    internal_url        => $heat_cfn_internal_url,
    admin_url           => $heat_cfn_admin_url,

    region              => $region,
    password            => $heat_password
  }

  if $trove_enabled {
    class {'::trove::keystone::auth':

      public_url        => $trove_public_url,
      internal_url      => $trove_internal_url,
      admin_url         => $trove_admin_url,

      region            => $region,
      password          => $trove_password
    }
  }

  if $magnum_enabled {
    class { '::magnum::keystone::auth':

      public_url          => $magnum_public_url,
      internal_url        => $magnum_internal_url,
      admin_url           => $magnum_admin_url,

      region              => $region,
      password            => $magnum_password
    }

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

}
