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
# == Class: cloud::network::metadata
#
# Network Metadata node
#
# === Parameters:
#
# [*enabled*]
#   (optional) State of the metadata service.
#   Defaults to true
#
# [*debug*]
#   (optional) Set log output to debug output
#   Defaults to true
#
# [*neutron_metadata_proxy_shared_secret*]
#   (optional) Shared secret to validate proxies Neutron metadata requests
#   Defaults to 'metadatapassword'
#
# [*nova_metadata_server*]
#   (optional) Hostname or IP of the Nova metadata server
#   Defaults to '127.0.0.1'
#
# [*ks_nova_internal_proto*]
#   (optional) Protocol for public endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
class cloud::network::metadata(
  $enabled                              = true,
  $debug                                = true,
  $neutron_metadata_proxy_shared_secret = 'asecreteaboutneutron',
  $nova_metadata_server                 = '127.0.0.1',
  $ks_nova_internal_proto               = 'http'
) {

  include 'cloud::network'
  include 'cloud::network::vswitch'

  class { 'neutron::agents::metadata':
    enabled          => $enabled,
    shared_secret    => $neutron_metadata_proxy_shared_secret,
    debug            => $debug,
    metadata_ip      => $nova_metadata_server,
    metadata_workers => $::neutron::agents::metadata::metadata_workers,
    metadata_protocol=> $ks_nova_internal_proto,
  }

}
