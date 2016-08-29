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
# == Class: cloud::volume
#
# Common class for volume nodes
#
# === Parameters:
#
# [*rabbit_hosts*]
#   (optional) List of RabbitMQ servers. Should be an array.
#   Defaults to ['127.0.0.1:5672']
#
# [*rabbit_password*]
#   (optional) Password to connect to cinder queues.
#   Defaults to 'rabbitpassword'
#
# [*storage_availability_zone*]
#   (optional) The storage availability zone
#   Defaults to 'nova'
#
class cloud::volume(

  $ks_cinder_internal_port    = 8776,

  $ks_cinder_user             = 'cinder',
  $ks_cinder_password         = 'cinderpassword',
  $ks_admin_tenant            = 'services',

  $ks_keystone_internal_host  = '127.0.0.1',
  $ks_keystone_internal_proto = 'http',
  $ks_keystone_internal_port  = 5000,
  $ks_keystone_admin_port     = 35357,

  $rabbit_hosts               = ['127.0.0.1:5672'],
  $rabbit_password            = 'rabbitpassword',

  $memcache_servers           = [],

  $storage_availability_zone  = 'nova',

) {

  include ::cinder::db
  include ::mysql::client

  class { '::cinder':
    rabbit_userid             => 'cinder',
    rabbit_hosts              => $rabbit_hosts,
    rabbit_password           => $rabbit_password,
    rabbit_virtual_host       => '/',
    storage_availability_zone => $storage_availability_zone
  }

  class { '::cinder::keystone::authtoken':

    username                       => $ks_cinder_user,
    password                       => $ks_cinder_password,
    project_name                   => $ks_admin_tenant,

    auth_url                       => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_admin_port}",
    auth_uri                       => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_internal_port}",

    memcached_servers              => $memcache_servers,
  }

  class { '::cinder::ceilometer': }
}
