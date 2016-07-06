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
# == Class: cloud::telemetry::alarming::client
#
class cloud::telemetry::alarming::client(
){

  include ::cloud::telemetry

  # TODO(mmalchuk): this workaround should be removed when
  # https://review.openstack.org/#/c/311762/ is merged
  package { 'python-aodhclient':
    ensure => 'present',
    tag    => 'openstack',
  }
}