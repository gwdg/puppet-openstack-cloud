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
# == Class: cloud::compute
#
# Common class for compute nodes
#
# === Parameters:
#
# [*rabbit_hosts*]
#   (optional) List of RabbitMQ servers. Should be an array.
#   Defaults to ['127.0.0.1:5672']
#
# [*rabbit_password*]
#   (optional) Password to connect to nova queues.
#   Defaults to 'rabbitpassword'
#
# [*ks_glance_internal_host*]
#   (optional) Internal Hostname or IP to connect to Glance API
#   Defaults to '127.0.0.1'
#
# [*ks_glance_internal_proto*]
#   (optional) Internal protocol to connect to Glance API
#   Defaults to 'http'
#
# [*glance_api_port*]
#   (optional) TCP port to connect to Glance API
#   Defaults to '9292'
#
# [*neutron_endpoint*]
#   (optional) Host running auth service.
#   Defaults to '127.0.0.1'
#
# [*neutron_protocol*]
#   (optional) Protocol to connect to Neutron service.
#   Defaults to 'http'
#
# [*neutron_password*]
#   (optional) Password to connect to Neutron service.
#   Defaults to 'neutronpassword'
#
# [*neutron_region_name*]
#   (optional) Name of the Neutron Region.
#   Defaults to 'RegionOne'
#
# [*memcache_servers*]
#   (optionnal) Memcached servers used by Keystone. Should be an array.
#   Defaults to ['127.0.0.1:11211']
#
# [*availability_zone*]
#   (optional) Name of the default Nova availability zone.
#   Defaults to 'RegionOne'
#
class cloud::compute(

  $rabbit_hosts             = ['127.0.0.1:5672'],
  $rabbit_password          = 'rabbitpassword',

  $ks_glance_internal_host  = '127.0.0.1',
  $ks_glance_internal_proto = 'http',
  $glance_api_port          = 9292,

  $neutron_endpoint         = '127.0.0.1',
  $neutron_protocol         = 'http',
  $neutron_password         = 'neutronpassword',
  $neutron_region_name      = 'RegionOne',

  $memcache_servers         = ['127.0.0.1:11211'],
  $availability_zone        = 'RegionOne',

  $upgrade_level            = undef,
) {

  class { '::nova':
    rabbit_userid               => 'nova',
    rabbit_hosts                => $rabbit_hosts,
    rabbit_password             => $rabbit_password,

    glance_api_servers          => "${ks_glance_internal_proto}://${ks_glance_internal_host}:${glance_api_port}",
    memcached_servers           => $memcache_servers,

    cinder_catalog_info         => 'volumev2:cinderv2:internalURL',
#    nova_shell                  => '/bin/bash',

    # Set upgrade levels
    upgrade_level_cells         => $upgrade_level,
    upgrade_level_cert          => $upgrade_level,
    upgrade_level_compute       => $upgrade_level,
    upgrade_level_conductor     => $upgrade_level,
    upgrade_level_console       => $upgrade_level,
    upgrade_level_consoleauth   => $upgrade_level,
    upgrade_level_intercell     => $upgrade_level,
    upgrade_level_network       => $upgrade_level,
    upgrade_level_scheduler     => $upgrade_level,
  }

  class { '::nova::cache': }

  class { '::nova::network::neutron':
    neutron_admin_password => $neutron_password,
    neutron_admin_auth_url => "${neutron_protocol}://${neutron_endpoint}:35357",
    neutron_auth_plugin    => 'password',
    neutron_url            => "${neutron_protocol}://${neutron_endpoint}:9696",
    neutron_region_name    => $neutron_region_name
  }

  nova_config {
    'DEFAULT/resume_guests_state_on_host_boot': value => false;
    'DEFAULT/servicegroup_driver':              value => 'mc';
    'DEFAULT/glance_num_retries':               value => '10';

    # Currently not set in nova module
    'upgrade_levels/baseapi':                   value => $upgrade_level;
  }

}
