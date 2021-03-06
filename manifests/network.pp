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
# == Class: cloud::network
#
# Common class for network nodes
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
# [*api_eth*]
#   (optional) Which interface we bind the Neutron API server.
#   Defaults to '127.0.0.1'
#
# [*dhcp_lease_duration*]
#   (optional) DHCP Lease duration (in seconds)
#   Defaults to '120'
#
# [*plugin*]
#   (optional) Neutron plugin name
#   Supported values: 'ml2'
#   Defaults to 'ml2'
#
# [*service_plugins*]
#   (optional) List of service plugin entrypoints to be loaded from the neutron
#   service_plugins namespace
#   Defaults to ['neutron.services.loadbalancer.plugin.LoadBalancerPlugin','neutron.services.metering.metering_plugin.MeteringPlugin','neutron.services.l3_router.l3_router_plugin.L3RouterPlugin']
#
class cloud::network(
  $api_eth                    = '127.0.0.1',
  $dhcp_lease_duration        = '120',
  $plugin                     = 'ml2',
  $service_plugins            = ['neutron.services.loadbalancer.plugin.LoadBalancerPlugin','neutron.services.metering.metering_plugin.MeteringPlugin','neutron.services.l3_router.l3_router_plugin.L3RouterPlugin'],
) {

  case $plugin {
    'ml2': {
      $core_plugin = 'neutron.plugins.ml2.plugin.Ml2Plugin'
    }
    default: {
      fail("${plugin} plugin is not supported.")
    }
  }

  class { '::neutron':
    allow_overlapping_ips   => true,
    debug                   => $debug,
    bind_host               => $api_eth,
    use_syslog              => $use_syslog,
    dhcp_agents_per_network => '2',
    core_plugin             => $core_plugin,
    service_plugins         => $service_plugins,
    dhcp_lease_duration     => $dhcp_lease_duration,
    report_interval         => '30',
  }

}
