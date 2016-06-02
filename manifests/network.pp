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
#   Supported values: 'ml2', 'n1kv', 'opencontrail'.
#   Defaults to 'ml2'
#
# [*service_plugins*]
#   (optional) List of service plugin entrypoints to be loaded from the neutron
#   service_plugins namespace
#   Defaults to ['neutron.services.loadbalancer.plugin.LoadBalancerPlugin','neutron.services.metering.metering_plugin.MeteringPlugin','neutron.services.l3_router.l3_router_plugin.L3RouterPlugin']
#
class cloud::network(
  $rabbit_hosts               = ['127.0.0.1:5672'],
  $rabbit_password            = 'rabbitpassword',
  $api_eth                    = '127.0.0.1',
  $dhcp_lease_duration        = '120',
  $plugin                     = 'ml2',
  $service_plugins            = ['neutron.services.loadbalancer.plugin.LoadBalancerPlugin','neutron.services.metering.metering_plugin.MeteringPlugin','neutron.services.l3_router.l3_router_plugin.L3RouterPlugin'],
  $lbaas_enabled              = false,
  $lbaas_service_provider     = 'LOADBALANCER:Haproxy:neutron_lbaas.services.loadbalancer.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default',
) {

  case $plugin {
    'ml2': {
      $core_plugin = 'neutron.plugins.ml2.plugin.Ml2Plugin'
    }
    'n1kv': {
      $core_plugin = 'neutron.plugins.cisco.network_plugin.PluginV2'
    }
    'opencontrail': {
      $core_plugin = 'neutron_plugin_contrail.plugins.opencontrail.contrail_plugin.NeutronPluginContrailCoreV2'
    }
    default: {
      fail("${plugin} plugin is not supported.")
    }
  }

  if $lbaas_enabled {
    Package['neutron'] -> Neutron_lbaas_service_config <||>
    
    neutron_lbaas_service_config {
      'service_providers/service_provider': value => $lbaas_service_provider;
    }
  }

  class { 'neutron':
    allow_overlapping_ips   => true,
    debug                   => $debug,
    rabbit_user             => 'neutron',
    rabbit_hosts            => $rabbit_hosts,
    rabbit_password         => $rabbit_password,
    rabbit_virtual_host     => '/',
    bind_host               => $api_eth,
    log_facility            => $log_facility,
    use_syslog              => $use_syslog,
    dhcp_agents_per_network => '2',
    core_plugin             => $core_plugin,
    service_plugins         => $service_plugins,
    dhcp_lease_duration     => $dhcp_lease_duration,
    report_interval         => '30',
  }

}
