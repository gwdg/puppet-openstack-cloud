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
# == Class: cloud::orchestration
#
# Orchestration common node
#
# === Parameters:
#
# [*ks_heat_public_host*]
#   (optional) Public Hostname or IP to connect to Heat API
#   Defaults to '127.0.0.1'
#
# [*ks_heat_public_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_heat_password*]
#   (optional) Password used by Heat to connect to Keystone API
#   Defaults to 'heatpassword'
#
# [*rabbit_hosts*]
#   (optional) List of RabbitMQ servers. Should be an array.
#   Defaults to ['127.0.0.1:5672']
#
# [*rabbit_password*]
#   (optional) Password to connect to heat queues.
#   Defaults to 'rabbitpassword'
#
# [*os_endpoint_type*]
#   (optional) The type of the OpenStack endpoint (public/internal/admin) URL
#   Defaults to 'publicURL'
#
class cloud::orchestration(

  $ks_heat_public_host        = '127.0.0.1',
  $ks_heat_public_proto       = 'http',
  $ks_heat_password           = 'heatpassword',

  $rabbit_hosts               = ['127.0.0.1:5672'],
  $rabbit_password            = 'rabbitpassword',

  $os_endpoint_type           = 'publicURL'
) {

  include ::mysql::client
  include ::heat::db

  class { '::heat':
    rabbit_hosts          => $rabbit_hosts,
    rabbit_password       => $rabbit_password,
    rabbit_userid         => 'heat',
  }

  class { '::heat::keystone::domain': 
    manage_domain => false,
    manage_user   => false,
    manage_role   => false,
  }

  class { '::heat::client': }

  heat_config {
    'clients/endpoint_type': value => $os_endpoint_type;
  }
}
