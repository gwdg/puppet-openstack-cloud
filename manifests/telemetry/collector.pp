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
#
# == Class: cloud::telemetry::collector
#
# Telemetry Collector nodes
#
# === Parameters:
#
#
class cloud::telemetry::collector(

  $gnocchi_url          = 'http://localhost:8041',
  $workers              = 1,

  $batch_size           = 100,
  $batch_timeout        = 5,

){
  include ::ceilometer::db
  include ::cloud::telemetry

  class { '::ceilometer::collector': 
    meter_dispatcher    => ['gnocchi'],
    collector_workers   => $workers,
  }

  class { '::ceilometer::dispatcher::gnocchi':
#    filter_service_activity   => false,
    filter_project            => 'services',
    url                       => $gnocchi_url,
#    archive_policy            => 'high',
    resources_definition_file => 'gnocchi_resources.yaml',
  }

  # Add some missing options for collector
  class { '::ceilometer::config':
    ceilometer_config => {
      'collector/batch_size'    => { value => $batch_size},
      'collector/batch_timeout' => { value => $batch_timeout}
    }
  }

}
