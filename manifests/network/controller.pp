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
# Network Controller node (API + Scheduler)
#
# === Parameters:
#
# [*ks_neutron_public_port*]
#   (optional) TCP port to connect to Neutron API from public network
#   Defaults to '9696'
#
# [*api_eth*]
#   (optional) Which interface we bind the Neutron server.
#   Defaults to '127.0.0.1'
#
# [*nova_admin_auth_url*]
#   (optional) Authorization URL for connection to nova in admin context.
#   Defaults to 'http://127.0.0.1:5000/v2.0'
#
# [*nova_admin_tenant_name*]
#   (optional) The name of the admin nova tenant
#   Defaults to 'services'
#
# [*nova_admin_password*]
#   (optional) Password for connection to nova in admin context.
#   Defaults to 'novapassword'
#
# [*nova_region_name*]
#   (optional) Name of nova region to use. Useful if keystone manages more than
#   one region.
#   Defaults to 'RegionOne'
#
# [*manage_ext_network*]
#   (optionnal) Manage or not external network with provider network API
#   Defaults to false.
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
# [*tenant_network_types*]
#   (optional) Handled tenant network types
#   Defaults to ['gre']
#   Possible value ['local', 'flat', 'vlan', 'gre', 'vxlan']
#
# [*type_drivers*]
#   (optional) Drivers to load
#   Defaults to ['gre', 'vlan', 'flat']
#   Possible value ['local', 'flat', 'vlan', 'gre', 'vxlan']
#
# [*plugin*]
#   (optional) Neutron plugin name
#   Supported values: 'ml2'
#   Defaults to 'ml2'
#
# [*l3_ha*]
#   (optional) Enable L3 agent HA
#   Defaults to false.
#
# [*router_distributed*]
#   (optional) Create distributed tenant routers by default
#   Right now, DVR is not compatible with l3_ha
#   Defaults to false
#
# [*provider_vlan_ranges*]
#   (optionnal) VLAN range for provider networks
#   Defaults to ['physnet1:1000:2999']
#
# [*flat_networks*]
#   (optionnal) List of physical_network names with which flat networks
#   can be created. Use * to allow flat networks with arbitrary
#   physical_network names.
#   Should be an array.
#   Default to ['public'].
#
# [*tunnel_id_ranges*]
#   (optional) GRE tunnel id ranges. used by he ml2 plugin
#   List of colon-separated id ranges
#   Defaults to ['1:10000']
#
# [*vni_ranges*]
#   (optional) VxLan Network ID range. used by the ml2 plugin
#   List of colon-separated id ranges
#   Defaults to ['1:10000']
#
# [*mechanism_drivers*]
#   (optional) Neutron mechanism drivers to run
#   List of drivers.
#   Note: if l3-ha is True, do not include l2population (not compatible in Juno).
#   Defaults to ['linuxbridge', 'openvswitch','l2population']
#
class cloud::network::controller(

  $ks_neutron_public_port           = 9696,
  $api_eth                          = '127.0.0.1',

  $tenant_name                      = 'services',
  $region_name                      = 'RegionOne',
  $manage_ext_network               = false,

  $firewall_settings                = {},
  $flat_networks                    = ['public'],
  $tenant_network_types             = ['gre'],
  $type_drivers                     = ['gre', 'vlan', 'flat'],
  $provider_vlan_ranges             = ['physnet1:1000:2999'],
  $plugin                           = 'ml2',
  $mechanism_drivers                = ['linuxbridge', 'openvswitch','l2population'],

  $l3_ha                            = false,
  $router_distributed               = false,
  $allow_automatic_l3agent_failover = false,
  $allow_automatic_dhcp_failover    = false,
  $network_auto_schedule            = false,

  # only needed by ml2 plugin
  $tunnel_id_ranges                 = ['1:10000'],
  $vni_ranges                       = ['1:10000'],
) {

  include ::mysql::client
  include ::neutron::quota
  include ::neutron::db
  include ::cloud::network

  if $l3_ha and $router_distributed {
    fail 'l3_ha and router_distributed are mutually exclusive, only one of them can be set to true'
  }

  validate_array($mechanism_drivers)
  if $l3_ha and member($mechanism_drivers, 'l2population') {
    fail 'l3_ha does not work with l2population mechanism driver in Juno.'
  }

  class { '::neutron::server':

    api_workers                         => $::neutron::server::api_workers,
    rpc_workers                         => $::neutron::server::rpc_workers,

    l3_ha                               => $l3_ha,
    router_distributed                  => $router_distributed,
    allow_automatic_l3agent_failover    => $allow_automatic_l3agent_failover,
    allow_automatic_dhcp_failover       => $allow_automatic_dhcp_failover,
    network_auto_schedule               => $network_auto_schedule,

    sync_db                             => true,
  }

  case $plugin {
    'ml2': {
      $core_plugin = 'neutron.plugins.ml2.plugin.Ml2Plugin'
      class { '::neutron::plugins::ml2':
        type_drivers          => $type_drivers,
        tenant_network_types  => $tenant_network_types,
        network_vlan_ranges   => $provider_vlan_ranges,
        tunnel_id_ranges      => $tunnel_id_ranges,
        vni_ranges            => $vni_ranges,
        flat_networks         => $flat_networks,
        mechanism_drivers     => $mechanism_drivers,
        enable_security_group => true
      }
    }

    default: {
      fail("${plugin} plugin is not supported.")
    }
  }

  class { '::neutron::server::notifications':
    tenant_name         => $tenant_name,
    region_name         => $region_name
  }

  if $manage_ext_network {
    neutron_network {'public':
      provider_network_type     => 'flat',
      provider_physical_network => 'public',
      shared                    => true,
      router_external           => true
    }
  }

  class { 'neutron::services::lbaas': }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow neutron-server access':
      port   => $ks_neutron_public_port,
      extras => $firewall_settings,
    }
  }

  @@haproxy::balancermember{"${::fqdn}-neutron_api":
    listening_service => 'neutron_api',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_neutron_public_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

}
