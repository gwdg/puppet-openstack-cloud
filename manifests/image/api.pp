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
# == Class: cloud::image::api
#
# Install API Image Server (Glance API)
#
# === Parameters:
#
# [*ks_glance_api_internal_port*]
#   (optional) TCP port to connect to Glance API from internal network
#   Defaults to '9292'
#
# [*ks_glance_registry_internal_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Defaults to 'http'
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
# [*openstack_vip*]
#   (optional) Hostname of IP used to connect to Glance registry
#   Defaults to '127.0.0.1'
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::image::api(

  $glance_backends                   = undef,

  $ks_glance_api_internal_port       = '9292',
  $ks_glance_registry_internal_port  = '9191',
  $ks_glance_registry_internal_proto = 'http',
  $ks_glance_password                = 'glancepassword',

  $api_eth                           = '127.0.0.1',
  $openstack_vip                     = '127.0.0.1',

  $firewall_settings                 = {},
  $container_formats                 = 'ami,ari,aki,bare,ovf,ova',
) {

  include ::glance::api::db

  if has_key($glance_backends, 'rbd') {
    $rbd_backends = $glance_backends['rbd']
    create_resources('::cloud::image::backend::rbd', $rbd_backends)
  } else {
    $rbd_backends = { }
  }

  if has_key($glance_backends, 'file') {
    $file_backends = $glance_backends['file']
    create_resources('::cloud::image::backend::file', $file_backends)
  } else {
    $file_backends = { }
  }

  class { '::glance::api':

    registry_host            => $openstack_vip,
    registry_port            => $ks_glance_registry_internal_port,

    registry_client_protocol => $ks_glance_registry_internal_proto,
    show_image_direct_url    => true,
    bind_host                => $api_eth,
    bind_port                => $ks_glance_api_internal_port,
    pipeline                 => 'keystone',
    known_stores             => keys(merge($rbd_backends, $file_backends)),
  }

  glance_api_config {
    'DEFAULT/notifier_driver':      value => 'noop';
    'DEFAULT/container_formats':    value => $container_formats;
  }

  class { '::glance::cache::cleaner': }
  class { '::glance::cache::pruner': }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow glance-api access':
      port   => $ks_glance_api_internal_port,
      extras => $firewall_settings,
    }
  }

  @@haproxy::balancermember{"${::fqdn}-glance_api":
    listening_service => 'glance_api',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_glance_api_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }
}
