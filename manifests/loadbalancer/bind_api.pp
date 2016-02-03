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
# Define::
#
# cloud::loadbalancer::bind_api
#
define cloud::loadbalancer::bind_api(
  $enable           = false,
  $port             = undef,
  $public_access    = false,
  $public_port      = undef,
  $options          = {}
){

  if $enable {
    if $public_access or $public_port {

      # Derive public port
      if $public_port {
         $public_port_real = $public_port
      }
      else {
         $public_port_real = $port
      }

      # Define public + internal endpoints
      haproxy::listen { $title:
        bind                => {
          # Internal binding via http
          "${::cloud::loadbalancer::vip_internal_ip}:${port}"               => [],

          # Public binding always via https
          "${::cloud::loadbalancer::vip_public_ip}:${public_port_real}"     => [ 'ssl', 'crt', '/etc/haproxy/ssl/certs.pem' ],
        },
        options             => $options,
      }
    } else {

      # Define only an internal endpoint
      haproxy::listen { $title:
        bind                => {
          # Internal binding via http
          "${::cloud::loadbalancer::vip_internal_ip}:${port}"   => [],
        },
        options             => $options,
      } 
    }
  }
}
