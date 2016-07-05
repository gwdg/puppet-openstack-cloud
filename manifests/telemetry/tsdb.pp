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
# Telemetry TSDB nodes
#
class cloud::telemetry::tsdb(
  $ks_keystone_internal_host      = '127.0.0.1',
  $ks_keystone_internal_proto     = 'http',
  $ks_keystone_internal_port      = '5000',
  $ks_keystone_admin_port         = '35357', 

  $ks_gnocchi_internal_port       = '8041',
  $ks_gnocchi_password            = 'gnocchipassword',

  $gnocchi_db_user                = 'magnum',
  $gnocchi_db_password            = 'magnumpassword',
  $gnocchi_db_host                = '127.0.0.1',
  $gnocchi_db_port                = 3306,

  $api_eth                        = '127.0.0.1',
  $region                         = 'RegionOne',
){

  include ::cloud::telemetry

  #service and enpoint
 # class { '::gnocchi::keystone::auth':
 #   admin_address    => '10.0.0.1',
 #   internal_address => '10.0.0.1',
 #   public_address   => '10.0.0.1',
 #   password         => $ks_gnocchi_password,
 #   region           => $region
 # }

  $encoded_user     = uriescape($gnocchi_db_user)
  $encoded_password = uriescape($gnocchi_db_password)

  class { '::gnocchi':
    database_connection => "mysql://${encoded_user}:${encoded_password}@${gnocchi_db_host}:${gnocchi_db_port}/gnocchi?charset=utf8",
  }

  class { '::gnocchi::api':
    host                  => $api_eth,
    port                  => $ks_gnocchi_internal_port,
    keystone_auth_uri     => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_internal_port}",
    keystone_identity_uri => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_admin_port}",
    keystone_password     => $ks_gnocchi_password,

    sync_db               => true
  }

  @@haproxy::balancermember{"${::fqdn}-gnocchi_api":
    listening_service => 'gnocci_api',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_gnocchi_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  include ::gnocchi::client
}