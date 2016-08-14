#
# Copyright (C) 2016 Piotr Kasprzak (piotr.kasprzak@gwdg.de)
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
# == Class: cloud::compute::db
#
# Compute DB class for compute api / conductor nodes
#
# === Parameters:
#
# [*nova_db_host*]
#   (optional) Hostname or IP address to connect to nova database
#   Defaults to '127.0.0.1'
#
# [*nova_db_use_slave*]
#   (optional) Enable slave connection for nova, this assume
#   the haproxy is used and mysql loadbalanced port for read operation is 3307
#   Defaults to false
#
# [*nova_db_user*]
#   (optional) Username to connect to nova database
#   Defaults to 'nova'
#
# [*nova_db_password*]
#   (optional) Password to connect to nova database
#   Defaults to 'novapassword'
#
# [*nova_db_idle_timeout*]
#   (optional) Timeout before idle SQL connections are reaped.
#   Defaults to 5000
#
#
class cloud::compute::db(

  $nova_db_host             = '127.0.0.1',
  $nova_db_user             = 'nova',
  $nova_db_password         = 'novapassword',

  $nova_api_db_host         = '127.0.0.1',
  $nova_api_db_user         = 'nova_api',
  $nova_api_db_password     = 'nova_apipassword',

  $nova_db_idle_timeout     = 5000,
  $nova_db_use_slave        = false,
  $nova_db_port             = 3306,
  $nova_db_slave_port       = 3307,

) {

  $encoded_user         = uriescape($nova_db_user)
  $encoded_password     = uriescape($nova_db_password)

  $encoded_user_api     = uriescape($nova_api_db_user)
  $encoded_password_api = uriescape($nova_api_db_password)


  if $nova_db_use_slave {
    $slave_connection_url       = "mysql://${encoded_user}:${encoded_password}@${nova_db_host}:${nova_db_slave_port}/nova?charset=utf8"
    $api_slave_connection_url   = "mysql://${encoded_user_api}:${encoded_password_api}@${nova_api_db_host}:${nova_db_slave_port}/nova_api?charset=utf8"
  } else {
    $slave_connection_url       = undef
    $api_slave_connection_url   = undef
  }

  class { '::nova::db':

    database_connection         => "mysql://${encoded_user}:${encoded_password}@${nova_db_host}:${nova_db_port}/nova?charset=utf8",
    slave_connection            => $slave_connection_url,

    api_database_connection     => "mysql://${encoded_user_api}:${encoded_password_api}@${nova_api_db_host}:${nova_db_port}/nova_api?charset=utf8",
    api_slave_connection        => $api_slave_connection_url,

    database_idle_timeout       => $nova_db_idle_timeout,
  }

}
