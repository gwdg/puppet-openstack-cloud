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
# == Class: cloud::compute::scheduler
#
# Compute Scheduler node
#
# === Parameters:
#
# [*scheduler_default_filters*]
#   (optional) A comma separated list of filters to be used by default
#   Defaults to false
#
class cloud::compute::scheduler(
  $scheduler_default_filters   = [],
  $scheduler_available_filters = [],
  $python_path                 = '/usr/lib/python2.7/dist-packages/'
){

  include ::cloud::compute

  class { '::nova::scheduler':
    enabled => true,
  }

  file { ["$python_path/gwdg/", "$python_path/gwdg/nova/",
          "$python_path/gwdg/nova/scheduler", "$python_path/gwdg/nova/scheduler/filters/"]:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  } ->

  file { ["$python_path/gwdg/__init__.py", "$python_path/gwdg/nova/__init__.py",
          "$python_path/gwdg/nova/scheduler/__init__.py",
          "$python_path/gwdg/nova/scheduler/filters/__init__.py"]:
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0644'
  }
    

  file { "$python_path/gwdg/nova/scheduler/filters/aggregate_domain_isolation.py":
    source   => 'puppet:///modules/cloud/filters/aggregate_domain_isolation.py',
    mode     => '0644',
    owner    => 'root',
    require  => File["$python_path/gwdg/nova/scheduler/filters/"]
  }

  class { '::nova::scheduler::filter':
    scheduler_default_filters   => $scheduler_default_filters,
    scheduler_available_filters => $scheduler_available_filters,
  }

}
