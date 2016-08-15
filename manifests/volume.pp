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
# [*cinder_db_host*]
#   (optional) Cinder database host
#   Defaults to '127.0.0.1'
#
# [*cinder_db_user*]
#   (optional) Cinder database user
#   Defaults to 'cinder'
#
# [*cinder_db_password*]
#   (optional) Cinder database password
#   Defaults to 'cinderpassword'
#
# [*cinder_db_idle_timeout*]
#   (optional) Timeout before idle SQL connections are reaped.
#   Defaults to 5000
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

  $cinder_db_host             = '127.0.0.1',
  $cinder_db_user             = 'cinder',
  $cinder_db_password         = 'cinderpassword',
  $cinder_db_idle_timeout     = 5000,
  $cinder_db_use_slave        = false,
  $cinder_db_port             = 3306,
  $cinder_db_slave_port       = 3307,

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

  $encoded_user     = uriescape($cinder_db_user)
  $encoded_password = uriescape($cinder_db_password)

  include ::mysql::client

  if $cinder_db_use_slave {
    $slave_connection_url = "mysql://${encoded_user}:${encoded_password}@${cinder_db_host}:${cinder_db_slave_port}/cinder?charset=utf8"
  } else {
    $slave_connection_url = undef
  }

  class { '::cinder::db':
    database_connection       => "mysql://${encoded_user}:${encoded_password}@${cinder_db_host}:${cinder_db_port}/cinder?charset=utf8",
    database_slave_connection => $slave_connection_url,
    database_idle_timeout     => $cinder_db_idle_timeout,
  }

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
