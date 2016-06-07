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
# == Class: cloud::image::registry
#
# Install Registry Image Server (Glance Registry)
#
# === Parameters:
#
# [*glance_db_host*]
#   (optional) Hostname or IP address to connect to glance database
#   Defaults to '127.0.0.1'
#
# [*glance_db_user*]
#   (optional) Username to connect to glance database
#   Defaults to 'glance'
#
# [*glance_db_password*]
#   (optional) Password to connect to glance database
#   Defaults to 'glancepassword'
#
# [*glance_db_idle_timeout*]
#   (optional) Timeout before idle SQL connections are reaped.
#   Defaults 5000
#
# [*ks_keystone_internal_host*]
#   (optional) Internal Hostname or IP to connect to Keystone API
#   Defaults to '127.0.0.1'
#
# [*ks_keystone_internal_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_glance_internal_host*]
#   (optional) Internal Hostname or IP to connect to Glance
#   Defaults to '127.0.0.1'
#
# [*ks_glance_registry_internal_port*]
#   (optional) TCP port to connect to Glance Registry from internal network
#   Defaults to '9191'
#
# [*ks_glance_password*]
#   (optional) Password used by Glance to connect to Keystone API
#   Defaults to 'glancepassword'
#
# [*api_eth*]
#   (optional) Which interface we bind the Glance API server.
#   Defaults to '127.0.0.1'
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::image::registry(

  $glance_db_host                   = '127.0.0.1',
  $glance_db_user                   = 'glance',
  $glance_db_password               = 'glancepassword',
  $glance_db_idle_timeout           = 5000,
  $glance_db_use_slave              = false,
  $glance_db_port                   = 3306,
  $glance_db_slave_port             = 3307,

  $ks_keystone_internal_host        = '127.0.0.1',
  $ks_keystone_internal_proto       = 'http',
  $ks_keystone_internal_port        = 5000,
  $ks_keystone_admin_port           = 35357,

  $ks_glance_internal_host          = '127.0.0.1',
  $ks_glance_registry_internal_port = '9191',
  $ks_glance_password               = 'glancepassword',

  $api_eth                          = '127.0.0.1',
  $firewall_settings                = {},
) {

  include ::mysql::client

  $encoded_user     = uriescape($glance_db_user)
  $encoded_password = uriescape($glance_db_password)

  if $glance_db_use_slave {
    $slave_connection_url = "mysql://${encoded_user}:${encoded_password}@${glance_db_host}:${glance_db_slave_port}/glance?charset=utf8"
  } else {
    $slave_connection_url = undef
  }

  class { '::glance::registry::db':
    database_connection         => "mysql://${encoded_user}:${encoded_password}@${glance_db_host}:${glance_db_port}/glance?charset=utf8",
    database_slave_connection   => $slave_connection_url,
    database_idle_timeout       => $glance_db_idle_timeout,
  }

  class { '::glance::registry':

    auth_uri              => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_internal_port}",
    identity_uri          => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_admin_port}",

    keystone_password     => $ks_glance_password,
    keystone_tenant       => 'services',
    keystone_user         => 'glance',

    bind_host             => $api_eth,
    bind_port             => $ks_glance_registry_internal_port,

    sync_db               => true,
  }

#  glance_registry_config {
#    'database/slave_connection':    value => $slave_connection_url;
#  }

#  exec {'glance_db_sync':
#    command => 'glance-manage db_sync',
#    user    => 'glance',
#    path    => '/usr/bin',
#    unless  => "/usr/bin/mysql glance -h ${glance_db_host} -u ${encoded_glance_user} -p${encoded_glance_password} -e \"show tables\" | /bin/grep Tables",
#    require => [Package['mysql_client'], Package['glance-registry']]
#  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow glance-registry access':
      port   => $ks_glance_registry_internal_port,
      extras => $firewall_settings,
    }
  }

  @@haproxy::balancermember{"${::fqdn}-glance_registry":
    listening_service => 'glance_registry',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_glance_registry_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }
}
