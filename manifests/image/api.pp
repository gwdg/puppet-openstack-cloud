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
# == Class: cloud::image::api
#
# Install API Image Server (Glance API)
#
# === Parameters:
#
# [*glance_db_host*]
#   (optional) Hostname or IP address to connect to glance database
#   Defaults to '127.0.0.1'
#
# [*glance_db_user*]
#   (optional) Username to connect to glance database
#   Defaults to 'glance'
#
# [*glance_db_password*]
#   (optional) Password to connect to glance database
#   Defaults to 'glancepassword'
#
# [*glance_db_idle_timeout*]
#   (optional) Timeout before idle SQL connections are reaped.
#   Defaults to 5000

# [*ks_keystone_internal_host*]
#   (optional) Internal Hostname or IP to connect to Keystone API
#   Defaults to '127.0.0.1'
#
# [*ks_keystone_internal_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_glance_internal_host*]
#   (optional) Internal Hostname or IP to connect to Glance
#   Defaults to '127.0.0.1'
#
# [*ks_glance_api_internal_port*]
#   (optional) TCP port to connect to Glance API from internal network
#   Defaults to '9292'
#
# [*ks_glance_registry_internal_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_glance_registry_internal_port*]
#   (optional) TCP port to connect to Glance Registry from internal network
#   Defaults to '9191'
#
# [*ks_glance_password*]
#   (optional) Password used by Glance to connect to Keystone API
#   Defaults to 'glancepassword'
#
# [*rabbit_host*]
#   (optional) IP or Hostname of one RabbitMQ server.
#   Defaults to '127.0.0.1'
#
# [*rabbit_password*]
#   (optional) Password to connect to glance queue.
#   Defaults to 'rabbitpassword'
#
# [*api_eth*]
#   (optional) Which interface we bind the Glance API server.
#   Defaults to '127.0.0.1'
#
# [*openstack_vip*]
#   (optional) Hostname of IP used to connect to Glance registry
#   Defaults to '127.0.0.1'
#
# [*glance_rbd_pool*]
#   (optional) Name of the Ceph pool which which store the glance images
#   Defaults to 'images'
#
# [*glance_rbd_user*]
#   (optional) User name used to acces to the glance rbd pool
#   Defaults to 'glance'
#
# [*backend*]
#   (optionnal) Backend to use to store images
#   Can be 'rbd', 'file', 'nfs' or 'swift'
#   Defaults to 'rbd'
#
# [*known_stores*]
#   (optionnal) Tell to Glance API which backends can be used
#   Can be 'rbd', 'http', 'file', or and 'swift'.
#   Should be an array.
#   Defaults to ['rbd', 'http']
#
# [*filesystem_store_datadir*]
#   (optional) Full path of data directory to store the images.
#   Defaults to '/var/lib/glance/images/'
#
# [*nfs_server*]
#   (optionnal) NFS device to mount
#   Example: 'nfs.example.com:/vol1'
#   Required when running 'nfs' backend.
#   Defaults to false
#
# [*nfs_options*]
#   (optional) NFS mount options
#   Example: 'nfsvers=3,noacl'
#   Defaults to 'defaults'
#
# [*pipeline*]
#   (optional) Partial name of a pipeline in your paste configuration file with the
#   service name removed.
#   Defaults to 'keystone'.
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::image::api(

  $glance_db_host                    = '127.0.0.1',
  $glance_db_user                    = 'glance',
  $glance_db_password                = 'glancepassword',
  $glance_db_idle_timeout            = 5000,
  $glance_db_use_slave               = false,
  $glance_db_port                    = 3306,
  $glance_db_slave_port              = 3307,

  $ks_keystone_internal_host         = '127.0.0.1',
  $ks_keystone_internal_proto        = 'http',
  $ks_keystone_internal_port         = 5000,
  $ks_keystone_admin_port            = 35357,

  $ks_glance_internal_host           = '127.0.0.1',
  $ks_glance_api_internal_port       = '9292',
  $ks_glance_registry_internal_port  = '9191',
  $ks_glance_registry_internal_proto = 'http',
  $ks_glance_password                = 'glancepassword',

  $rabbit_password                   = 'rabbit_password',
  $rabbit_host                       = '127.0.0.1',

  $api_eth                           = '127.0.0.1',
  $openstack_vip                     = '127.0.0.1',

  $glance_rbd_pool                   = 'images',
  $glance_rbd_user                   = 'glance',
  $glance_rbd_key                    = 'key',

  $backend                           = 'rbd',
  $known_stores                      = ['rbd', 'http'],
  $filesystem_store_datadir          = '/var/lib/glance/images/',
  $nfs_server                        = false,
  $nfs_share                         = undef,
  $nfs_options                       = 'defaults',
  $pipeline                          = 'keystone',
  $firewall_settings                 = {},
  $container_formats                 = 'ami,ari,aki,bare,ovf,ova',
) {

  $encoded_user     = uriescape($glance_db_user)
  $encoded_password = uriescape($glance_db_password)

  if $glance_db_use_slave {
    $slave_connection_url = "mysql://${encoded_user}:${encoded_password}@${glance_db_host}:${glance_db_slave_port}/glance?charset=utf8"
  } else {
    $slave_connection_url = undef
  }

  class { '::glance::api::db':
    database_connection         => "mysql://${encoded_user}:${encoded_password}@${glance_db_host}:${glance_db_port}/glance?charset=utf8",
    database_idle_timeout       => $glance_db_idle_timeout,
    database_slave_connection   => $slave_connection_url,
  }

  class { '::glance::api':

    registry_host            => $openstack_vip,
    registry_port            => $ks_glance_registry_internal_port,

    auth_uri                 => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_internal_port}",
    identity_uri             => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_admin_port}",

    registry_client_protocol => $ks_glance_registry_internal_proto,
    keystone_password        => $ks_glance_password,
    keystone_tenant          => 'services',
    keystone_user            => 'glance',
    show_image_direct_url    => true,
    bind_host                => $api_eth,
    bind_port                => $ks_glance_api_internal_port,
    pipeline                 => 'keystone',
    known_stores             => $known_stores,
  }

  glance_api_config {
    'DEFAULT/notifier_driver':      value => 'noop';
    'DEFAULT/container_formats':    value => $container_formats;
  }

  if ($backend == 'rbd') {

    # Handle ceph.conf + ceph packages
    include ::cloud::storage::rbd

    package { 'ceph':
      ensure  => $package_ensure,
      name    => 'ceph-common',
    } 

    # Configure Glance rbd backend
    class { '::glance::backend::rbd':
      rbd_store_user            => $glance_rbd_user,
      rbd_store_pool            => $glance_rbd_pool,
      rbd_store_chunk_size      => 8,
      rados_connect_timeout     => 0,
    }

    # Set client key for cephx
    ceph::key { "client.${glance_rbd_user}":
        secret          => $glance_rbd_key,
        user            => 'glance',
        group           => 'glance',
        keyring_path    => "/etc/ceph/ceph.client.${glance_rbd_user}.keyring",
        notify          => Service['glance-api','glance-registry'],
    }

#    Concat::Fragment <<| title == 'ceph-client-os' |>>

  } elsif ($backend == 'file') {

    class { '::glance::backend::file':
      filesystem_store_datadir => $filesystem_store_datadir
    }

  } elsif ($backend == 'swift') {

    class { '::glance::backend::swift':
      swift_store_user                    => 'services:glance',
      swift_store_key                     => $ks_glance_password,
      swift_store_auth_address            => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:35357/v2.0/",
      swift_store_create_container_on_put => true,
    }

  } elsif ($backend == 'nfs') {

    include ::nfs::client

    nfs::client::mount { '/var/lib/glance/images':

      mount     => '/var/lib/glance/images',

      server    => $nfs_server,
      share     => "${nfs_share}/images",
      options   => $nfs_options,

      owner     => 'glance',
      group     => 'glance',

      require   => Package['glance-api'],
    }

    nfs::client::mount { '/var/lib/glance/image-cache':
      
      mount     => '/var/lib/glance/image-cache',

      server    => $nfs_server,
      share     => "${nfs_share}/image-cache",
      options   => $nfs_options,

      owner     => 'glance',
      group     => 'glance',

      require   => Package['glance-api'],                                                                                                                                                                   
    }

    class { '::glance::backend::file':
      filesystem_store_datadir => $filesystem_store_datadir
    }

  } else {
    fail("${backend} is not a Glance supported backend.")
  }

  class { '::glance::cache::cleaner': }
  class { '::glance::cache::pruner': }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow glance-api access':
      port   => $ks_glance_api_internal_port,
      extras => $firewall_settings,
    }
  }

  @@haproxy::balancermember{"${::fqdn}-glance_api":
    listening_service => 'glance_api',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_glance_api_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }
}
