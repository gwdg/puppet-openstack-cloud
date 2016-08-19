#
# Copyright (C) 2014 gwdg <gwdg@gwdg.de>
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
# Telemetry Alarming Engine - AODH
#
class cloud::telemetry::alarming::engine(

  $rabbit_hosts               = ['127.0.0.1:5672'],
  $rabbit_password            = 'rabbitpassword',
  
  $db_user                    = 'aodh',
  $db_password                = 'aodhpassword',
  $db_host                    = '127.0.0.1',
  $db_port                    = 3306,
  $db_idle_timeout            = 5000,

  $ks_keystone_internal_host  = '127.0.0.1',
  $ks_keystone_internal_port  = '5000',
  $ks_keystone_internal_proto = 'http',
  $ks_aodh_password           = 'aodhpassword',

  $gnocchi_url                = undef,

  $os_endpoint_type           = 'publicURL'
){

  include ::cloud::telemetry

  class { '::aodh': 
    rabbit_hosts            => $rabbit_hosts,
    rabbit_password         => $rabbit_password,
    rabbit_userid           => 'aodh',
    gnocchi_url             => $gnocchi_url,
  }

  class { '::aodh::auth':
    auth_url           => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_internal_port}/v2.0",
    auth_password      => $ks_aodh_password,
    auth_region        => $region,
    auth_endpoint_type => $os_endpoint_type,
  }

  $encoded_user     = uriescape($db_user)
  $encoded_password = uriescape($db_password)

  class { '::aodh::db':
    database_connection   => "mysql://${encoded_user}:${encoded_password}@${db_host}:${db_port}/aodh?charset=utf8",
    database_idle_timeout => $db_idle_timeout,
  }
}
