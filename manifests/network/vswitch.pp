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
# Network vswitch class
#
# === Parameters:
#
# [*driver*]
#   (optional) Neutron vswitch driver
#   Supported values: 'ml2_ovs', 'ml2_lb'
#   Defaults to 'ml2_ovs'
#
# [*external_int*]
#   (optionnal) Network interface to bind the external provider network
#   Defaults to 'eth1'.
#
# [*external_bridge*]
#   (optionnal) OVS bridge used to bind external provider network
#   Defaults to 'br-pub'.
#
# [*manage_ext_network*]
#   (optionnal) Manage or not external network with provider network API
#   Defaults to false.
#
# [*tunnel_eth*]
#   (optional) Interface IP used to build the tunnels
#   Defaults to '127.0.0.1'
#
# [*tunnel_typeis]
#   (optional) List of types of tunnels to use when utilizing tunnels
#   Defaults to ['gre']
#
# [*provider_bridge_mappings*]
#   (optional) List of <physical_network>:<bridge>
#
# [*enable_distributed_routing*]
#   (optional) Enable support for distributed routing on L2 agent.
#   Defaults to false.
#
# [*tunnel_types*]
#   (optional) List of types of tunnels to use when utilizing tunnels.
#   Supported tunnel types are: vxlan.
#   Defaults to ['gre']
#
# [*enable_tunneling*]
#   (optional) Enable or not tunneling.
#   Should be disable if using VLAN but enabled if using GRE or VXLAN.
#   Defailts to true
#
# [*l2_population*]
#   (optional) Enable or not L2 population.
#   If enabled, should be part of mechanism_drivers in cloud::network::controller.
#   Should be disabled if running L3 HA with VRRP in Juno.
#   Defaults to true
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::network::vswitch(
  # common
  $driver                     = 'ml2_ovs',
  $manage_ext_network         = false,
  $external_int               = 'eth1',
  $external_bridge            = 'br-pub',
  $firewall_settings          = {},
  # common to ml2
  $tunnel_types               = ['gre'],
  $tunnel_eth                 = '127.0.0.1',
  $enable_tunneling           = true,
  $l2_population              = true,
  # ml2_ovs
  $provider_bridge_mappings   = ['public:br-pub'],
  $enable_distributed_routing = false,
) {

  include ::cloud::network

  case $driver {

    'ml2_ovs': {
      class { '::neutron::agents::ml2::ovs':
        enable_tunneling           => $enable_tunneling,
        l2_population              => $l2_population,
        polling_interval           => '15',
        tunnel_types               => $tunnel_types,
        bridge_mappings            => $provider_bridge_mappings,
        local_ip                   => $tunnel_eth,
        enable_distributed_routing => $enable_distributed_routing
      }
    }

    'ml2_lb': {
      class { '::neutron::agents::ml2::linuxbridge':
        l2_population    => $l2_population,
        polling_interval => '15',
        tunnel_types     => $tunnel_types,
        local_ip         => $tunnel_eth
      }
    }

    default: {
      fail("${driver} driver is not supported.")
    }
  }

  if $manage_ext_network {
    vs_port {$external_int:
      ensure => present,
      bridge => $external_bridge
    }
  }

  if $::cloud::manage_firewall {
    if ('gre' in $tunnel_types) {
      cloud::firewall::rule{ '100 allow gre access':
        port   => undef,
        proto  => 'gre',
        extras => $firewall_settings,
      }
    }
    if ('vxlan' in $tunnel_types) {
      cloud::firewall::rule{ '100 allow vxlan access':
        port   => '4789',
        proto  => 'udp',
        extras => $firewall_settings,
      }
    }
  }

}
