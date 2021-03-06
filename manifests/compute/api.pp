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
# == Class: cloud::compute::api
#
# Install a Nova-API node
#
# === Parameters:
#
# [*ks_nova_password*]
#   (optional) Password used by Nova to connect to Keystone API
#   Defaults to 'novapassword'
#
# [*neutron_metadata_proxy_shared_secret*]
#   (optional) Shared secret to validate proxies Neutron metadata requests
#   Defaults to 'metadatapassword'
#
# [*api_eth*]
#   (optional) Hostname or IP to bind Nova API.
#   Defaults to '127.0.0.1'
#
# [*ks_nova_public_port*]
#   (optional) TCP port for bind Nova API.
#   Defaults to '8774'
#
# [*ks_metadata_public_port*]
#   (optional) TCP port for bind Nova metadata API.
#   Defaults to '8775'
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::compute::api(

  $neutron_metadata_proxy_shared_secret = 'metadatapassword',

  $api_bind_address                     = hiera('nova::api::api_eth'),
  $metadata_listen                      = hiera('nova::api::api_eth'),

  $ks_nova_public_port                  = '8774',
  $ks_metadata_public_port              = '8775',

  $firewall_settings                    = {},
){

  include ::nova::params
  include ::nova::db
  include ::nova::cron::archive_deleted_rows
  include ::cloud::compute
  include ::cloud::params
  include ::apache::mod::status

  class { '::nova::api': }

  # Use WSGI
  class {'::nova::wsgi::apache_api':
    servername  => $::fqdn,
    api_port    =>  $ks_nova_public_port,
    workers     => 1,
    # Use multiprocessing defaults
    threads     => $::processorcount,
    ssl         => false
  }
  
  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow nova-api access':
      port   => $ks_nova_public_port,
      extras => $firewall_settings,
    }
    cloud::firewall::rule{ '100 allow nova-metadata access':
      port   => $ks_metadata_public_port,
      extras => $firewall_settings,
    }
  }

  @@haproxy::balancermember{"${::fqdn}-compute_api_nova":
    listening_service => 'nova_api',
    server_names      => $::hostname,
    ipaddresses       => $api_bind_address,
    ports             => $ks_nova_public_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  @@haproxy::balancermember{"${::fqdn}-compute_api_metadata":
    listening_service => 'metadata_api',
    server_names      => $::hostname,
    ipaddresses       => $metadata_listen,
    ports             => $ks_metadata_public_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }
}
