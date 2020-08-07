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
# == Class: cloud::storage::rbd
#
# === Parameters:
#
#
class cloud::storage::rbd (

  $enable               = false,

  # Special ceph.conf client setup for VMs
  $compute_node         = false,

  $ceph_confs           = {},

  $package_ensure       = 'latest',

) {
  if $enable {

    # Install ceph client packages
    $packages = ['python-rbd', 'ceph-common']

    package { 'ceph':
      ensure  => $package_ensure,
      name    => 'ceph-common',
    } 

    package { 'python-rbd':
      ensure  => $package_ensure,
    }

    # Setup ceph.conf
#    file { '/etc/ceph/ceph.conf':
#      content => template('cloud/storage/ceph/ceph.conf.erb'),
#      require => Package['ceph']
#    }

    create_resources(file, $ceph_confs)

    Exec {
      path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'
    }
  }

}
