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
# == Class: cloud::database::dbaas
#
# Common class to install OpenStack Database as a Service (Trove)
#
# === Parameters:
#
# [*rabbit_hosts*]
#   (optional) List of RabbitMQ servers. Should be an array.
#   Defaults to ['127.0.0.1:5672']
#
# [*rabbit_password*]
#   (optional) Password to connect to nova queues.
#   Defaults to 'rabbitpassword'
#
# [*nova_admin_username*]
#   (optional) Trove username used to connect to nova.
#   Defaults to 'trove'
#
# [*nova_admin_password*]
#   (optional) Trove password used to connect to nova.
#   Defaults to 'trovepassword'
#
# [*nova_admin_tenant_name*]
#   (optional) Trove tenant name used to connect to nova.
#   Defaults to 'services'
#
class cloud::database::dbaas(

  $rabbit_hosts                 = ['127.0.0.1:5672'],
  $rabbit_password              = 'rabbitpassword',

  $nova_admin_username          = 'trove',
  $nova_admin_tenant_name       = 'services',
  $nova_admin_password          = 'trovepassword',
) {

  include ::mysql::client
  include ::trove::db

  class { '::trove':

    rabbit_hosts                 => $rabbit_hosts,
    rabbit_password              => $rabbit_password,
    rabbit_userid                => 'trove',

    nova_proxy_admin_pass        => $nova_admin_password,
    nova_proxy_admin_user        => $nova_admin_username,
    nova_proxy_admin_tenant_name => $nova_admin_tenant_name
  }
}
