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
# == Class: cloud::telemetry
#
# Common telemetry class, used by Controller, Storage,
# Network and Compute nodes
#
# === Parameters:
#
# [*ceilometer_secret*]
#   Secret key for signing messages.
#   Defaults to 'ceilometersecret'
#
# [*rabbit_hosts*]
#   (optional) List of RabbitMQ servers. Should be an array.
#   Defaults to ['127.0.0.1:5672']
#
# [*rabbit_password*]
#   (optional) Password to connect to nova queues.
#   Defaults to 'rabbitpassword'
#
# [*ks_keystone_internal_host*]
#   (optional) Internal Hostname or IP to connect to Keystone API
#   Defaults to '127.0.0.1'
#
# [*ks_keystone_internal_proto*]
#   (optional) Protocol for public endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_keystone_internal_port*]
#   (optional) TCP port to connect to Keystone API from internal network
#   Defaults to '5000'
#
# [*ks_keystone_admin_host*]
#   (optional) Admin Hostname or IP to connect to Keystone API
#   Defaults to '127.0.0.1'
#
# [*ks_keystone_public_host*]
#   (optional) Public Hostname or IP to connect to Keystone API
#   Defaults to '127.0.0.1'
#
# [*ks_ceilometer_password*]
#   (optional) Password used by Ceilometer to connect to Keystone API
#   Defaults to 'ceilometerpassword'
#
# [*region*]
#   (optional) the keystone region of this node
#   Defaults to 'RegionOne'
#
# [*os_endpoint_type*]
#   (optional) The type of the OpenStack endpoint (public/internal/admin) URL
#   Defaults to 'publicURL'
#
class cloud::telemetry(
  $ceilometer_secret          = 'ceilometersecret',

  $rabbit_hosts               = ['127.0.0.1:5672'],
  $rabbit_password            = 'rabbitpassword' ,

  $auth_uri                   = false,
  $memcache_servers           = [],

  $ks_ceilometer_password     = 'ceilometerpassword',

  $region                     = 'RegionOne',
  $os_endpoint_type           = 'publicURL',
  $metering_time_to_live      = 2592000,
){

  class { '::ceilometer':

    metering_secret         => $ceilometer_secret,

    memcached_servers       => $memcache_servers,

    rabbit_hosts            => $rabbit_hosts,
    rabbit_password         => $rabbit_password,
    rabbit_userid           => 'ceilometer',

    metering_time_to_live   => $metering_time_to_live,
  }

  ceilometer_config {
    'service_credentials/os_endpoint_type': value => $os_endpoint_type;
  }

  class { '::ceilometer::agent::auth':
    auth_url      => $auth_uri,
    auth_password => $ks_ceilometer_password,
    auth_region   => $region
  }

}
