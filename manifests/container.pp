#
# Copyright (C) 2016 GWDG <support@gwdg.com>
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
# == Class: cloud::container
#
# Container common node
#
# === Parameters:
#
class cloud::container(

  $rabbit_hosts             = ['127.0.0.1:5672'],
  $rabbit_password          = 'rabbitpassword',

){

  include ::mysql::client
  include ::magnum::db

  file { '/tmp/setup_magnum.sh':
    ensure => file,
    source => 'puppet:///modules/cloud/magnum/setup_magnum.sh',
    owner  => root,
    group  => root,
    mode   => 'u+x',
    audit  => content,
  } 

  exec { '/tmp/setup_magnum.sh':
    subscribe => File['/tmp/setup_magnum.sh'],
    refreshonly => true,
  }

  class { '::magnum':
	rabbit_hosts          => $rabbit_hosts,
	rabbit_password       => $rabbit_password,
	rabbit_userid         => 'magnum',

    require               => Exec ['/tmp/setup_magnum.sh']
  }->
  magnum_config {
	'certificates/cert_manager_type' :   value => 'local';
	'certificates/storage_path' :        value => '/var/lib/magnum/certificates/';
  }

  exec { 'magnum-db-sync':
    command     => "magnum-db-manage upgrade",
    path        => '/usr/bin:/usr/local/bin/',
    refreshonly => true,
    subscribe   => [Exec['/tmp/setup_magnum.sh'], Magnum_config['database/connection']],
  }

  Exec['magnum-manage db_sync'] ~> Service<| title == 'magnum' |>
}
