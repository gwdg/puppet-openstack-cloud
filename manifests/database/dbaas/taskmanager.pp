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
# == Class: cloud::database::dbaas::taskmanager
#
# Class to install Taskmanager service of OpenStack Database as a Service (Trove)
#

class cloud::database::dbaas::taskmanager(
  $ks_keystone_internal_host  = '127.0.0.1',
  $ks_keystone_internal_port  = '5000',
  $ks_keystone_internal_proto = 'http',
  $debug                      = true,
  $verbose                    = true,
  $use_syslog                 = true
) {

  include 'cloud::database::dbaas'

  class { 'trove::taskmanager':
    auth_url   => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_internal_port}/v2.0",
    debug      => $debug,
    verbose    => $verbose,
    use_syslog => $use_syslog
  }

}
