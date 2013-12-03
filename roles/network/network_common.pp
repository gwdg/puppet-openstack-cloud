#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
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
# Common networking
#

class os_network_common(
  $neutron_db_host     = $os_params::neutron_db_host,
  $neutron_db_user     = $os_params::neutron_db_user,
  $neutron_db_password = $os_params::neutron_db_password,
  $verbose             = $os_params::verbose,
  $debug               = $os_params::debug,
  $rabbit_hosts        = $os_params::rabbit_hosts,
  $rabbit_hosts        = $os_params::rabbit_password,
) {

  $encoded_user = uriescape($neutron_db_user)
  $encoded_password = uriescape($neutron_db_password)

  class { 'neutron':
    allow_overlapping_ips   => true,
    verbose                 => $verbose,
    debug                   => $debug,
    rabbit_user             => 'neutron',
    rabbit_hosts            => $rabbit_hosts,
    rabbit_password         => $rabbit_password,
    rabbit_virtual_host     => '/',
    dhcp_agents_per_network => 2
  }

  class { 'neutron::plugins::ovs':
    sql_connection      => "mysql://${encoded_user}:${encoded_password}@${neutron_db_host}/neutron?charset=utf8",
    tenant_network_type => 'gre',
    network_vlan_ranges => false
  }

}