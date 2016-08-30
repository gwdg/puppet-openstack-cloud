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

  $auth_uri                         = 'http://127.0.0.1:5000/',
  $identity_uri                     = 'http://127.0.0.1:35357/',

  $memcache_servers                 = [],

  $ks_glance_internal_host          = '127.0.0.1',
  $ks_glance_registry_internal_port = '9191',
  $ks_glance_password               = 'glancepassword',

  $api_eth                          = '127.0.0.1',
  $firewall_settings                = {},
) {

  include ::glance::registry::db
  include ::mysql::client

  class { '::glance::registry':

    auth_uri              => $auth_uri, 
    identity_uri          => $identity_uri,

    memcached_servers     => $memcache_servers,

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
