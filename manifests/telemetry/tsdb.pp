#
# Copyright (C) 2016 gwdg <gwdg@gwdg.de>
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

  $auth_uri                     = false,
  $identity_uri                 = false,

  $ks_gnocchi_internal_port     = 8041,
  $ks_gnocchi_password          = 'gnocchipassword',

  $influxdb_host                = '127.0.0.1',
  $influxdb_port                = 8086,
  $influxdb_management_port     = 8083,

  $api_eth                      = '127.0.0.1',
  $region                       = 'RegionOne',
){

  include ::cloud::telemetry
  include ::gnocchi::client
  include ::gnocchi::db
  include ::gnocchi::storage::influxdb
  include ::gnocchi::metricd

  class { '::gnocchi':
  }

  class { '::gnocchi::api':
    host                  => $api_eth,
    port                  => $ks_gnocchi_internal_port,

    # Use WSGI
    service_name          => 'httpd',

    keystone_auth_uri     => $auth_uri,
    keystone_identity_uri => $identity_uri,
    keystone_password     => $ks_gnocchi_password,

    sync_db               => true
  }

  class {'::gnocchi::wsgi::apache':

    servername  => $::fqdn,
    port        => $ks_gnocchi_internal_port,

    # Use multiprocessing defaults
    workers     => 1,
    threads     => $::processorcount,

    ssl         => false
  }

  # Active mod status for monitoring of Apache
  class { 'apache::mod::status':
    allow_from => ['127.0.0.1'],
  }

  # Fix: create default archive policies (this is done automatically in newer versions of Gnocch [v2.0+])
  exec { 'create-gnocchi-default-policies':
    command     =>  "/bin/bash -c 'source /root/auth_admin.sh && gnocchi archive-policy create -d granularity:5m,points:12 -d granularity:1h,points:24 -d granularity:1d,points:30 low && gnocchi archive-policy create -d granularity:60s,points:60 -d granularity:1h,points:168 -d granularity:1d,points:365 medium && gnocchi archive-policy create -d granularity:1s,points:86400 -d granularity:1m,points:43200 -d granularity:1h,points:8760 high && gnocchi archive-policy-rule create -a low -m \"*\" default'",
    unless      => "/bin/bash -c 'source /root/auth_admin.sh && gnocchi archive-policy show low'",
    require     => [ Package['python-gnocchiclient'], Service['apache2'] ],
    path        => ['/usr/bin', '/bin'],
    tries       => '3',
    try_sleep   => '5',
  }

  @@haproxy::balancermember{"${::fqdn}-gnocchi_api":
    listening_service => 'gnocchi_api',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_gnocchi_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  @@haproxy::balancermember{"${::fqdn}-influxdb":
    listening_service => 'influxdb',
    server_names      => 'influxdb',
    ipaddresses       => $influxdb_host,
    ports             => $influxdb_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  @@haproxy::balancermember{"${::fqdn}-influxdb-management":
    listening_service => 'influxdb_management',
    server_names      => 'influxdb',
    ipaddresses       => $influxdb_host,
    ports             => $influxdb_management_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

}
