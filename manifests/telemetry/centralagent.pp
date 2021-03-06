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
# == Class: cloud::telemetry::centralagent
#
# Telemetry Central Agent node (should be run once)
# Could be managed by spof node as Active / Passive.
#
# === Parameters:
#
# [*enabled*]
#   (optional) State of the telemetry central agent service.
#   Defaults to true
#
# [*coordination_url*]
#   (optional) The url to use for distributed group membership coordination.
#   Defaults to undef
#
class cloud::telemetry::centralagent(
  $enabled          = true,
  $coordination_url = undef,
){

  include ::cloud::telemetry

  class { '::ceilometer::agent::central':
    enabled          => $enabled,
    coordination_url => $coordination_url,
  }

}
