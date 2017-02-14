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

  $auth_uri                   = false,
  $auth_url                   = $::os_service_default,

  $memcache_servers           = [],

  $ks_aodh_internal_port      = 8042,

  $api_eth                    = '127.0.0.1',
  $ks_aodh_password           = 'aodhpassword',
){

  include ::cloud::telemetry

  class { '::aodh::api':

    keystone_auth_uri     => $auth_uri,
    keystone_auth_url     => $auth_url,
    keystone_password     => $ks_aodh_password,
    memcached_servers     => $memcache_servers,

    # Use WSGI
    service_name          => 'httpd',

    host                  => $api_eth,
    port                  => $ks_aodh_internal_port,

    sync_db               => true,
  }

  # WSGI setup
  class {'::aodh::wsgi::apache':

    servername  => $::fqdn,
    port        => $ks_aodh_internal_port,

    # Use multiprocessing defaults
    workers     => 1,
    threads     => $::processorcount,

    ssl         => false
  }

  # Active mod status for monitoring of Apache
  class { 'apache::mod::status':
    allow_from => ['127.0.0.1'],
  }

  @@haproxy::balancermember{"${::fqdn}-aodh_api":
    listening_service => 'aodh_api',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_aodh_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }
}
