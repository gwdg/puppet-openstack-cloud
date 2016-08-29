#
# Copyright (C) 2014 gwdg <gwdg@gwdg.de>
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
# == Class: cloud::telemetry::alarming::api
#
class cloud::telemetry::alarming::api(
  $ks_aodh_internal_port      = 8042,
  $ks_keystone_internal_host  = '127.0.0.1',
  $ks_keystone_internal_port  = '5000',
  $ks_keystone_internal_proto = 'http',
  $ks_keystone_admin_port     = '35357',
  $api_eth                    = '127.0.0.1',
  $ks_aodh_password           = 'aodhpassword',
){

  include ::cloud::telemetry

  class { '::aodh::api':
    keystone_auth_uri     => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_internal_port}/v2.0",
    keystone_identity_uri => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_admin_port}",
    keystone_password     => $ks_aodh_password,
    host                  => $api_eth,
    port                  => $ks_aodh_internal_port,

    sync_db               => true,
  }

  @@haproxy::balancermember{"${::fqdn}-aodh_api":
    listening_service => 'aodh_api',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_aodh_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }
}