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

  $auth_url                   = 'http://localhost:5000/v2.0',
  $ks_aodh_password           = 'aodhpassword',

  $gnocchi_url                = undef,

  $os_endpoint_type           = 'publicURL'
){

  include ::aodh::db
  include ::cloud::telemetry

  class { '::aodh': 
    gnocchi_url             => $gnocchi_url,
  }

  class { '::aodh::auth':
    auth_url           => $auth_url,
    auth_password      => $ks_aodh_password,
    auth_region        => $region,
    auth_endpoint_type => $os_endpoint_type,
  }
}
