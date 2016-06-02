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
# [*mongo_nodes*]
#   (optional) An array of mongo db nodes
#   Defaults to ['127.0.0.1:27017']
#
# [*replicaset_enabled*]
#   (optional) Enable or not mongo replicat (using ceilometer name)
#   Defaults to true
#
class cloud::telemetry::collector(
  $mongo_nodes              = ['127.0.0.1:27017'],
  $replica_set_name         = 'ceilometer',
){

  include 'cloud::telemetry'

  $s_mongo_nodes = join($mongo_nodes, ',')

#  mongodb_conn_validator { $mongo_nodes:
#    before => Class['ceilometer::db']
#  }

  class { 'ceilometer::db':
    database_connection => "mongodb://${s_mongo_nodes}/ceilometer?replicaSet=${replica_set_name}",
    sync_db             => true,
  }

  class { 'ceilometer::collector': }

}
