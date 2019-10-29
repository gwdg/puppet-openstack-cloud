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
# == Class: cloud::compute::placement
#
# Install a Nova-API placement service
#
#
class cloud::compute::placement(
  $public_port = '8778',
  $bind_address = undef,
){
  include ::nova::params
  include ::nova::db
  include ::nova::cron::archive_deleted_rows
  include ::cloud::compute
  include ::cloud::params
  include ::apache::mod::status

  
  class { '::nova::placement': }

  class {'::nova::wsgi::apache_placement':
    servername  => $::fqdn,
    api_port    => $public_port,
    workers     => 1,
    threads     => $::processorcount,
    ssl         => false
  }

  @@haproxy::balancermember{"${::fqdn}-compute_api_nova_placement_api":
    listening_service => 'nova_placement_api',
    server_names      => $::hostname,
    ipaddresses       => $bind_address,
    ports             => $public_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }
}
