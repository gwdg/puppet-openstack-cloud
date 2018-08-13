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
# Volume storage
#
# === Parameters
#
# [*ks_keystone_internal_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_keystone_internal_host*]
#   (optional) Internal Hostname or IP to connect to Keystone API
#   Defaults to '127.0.0.1'
#
# [*ks_keystone_internal_port*]
#   (optional) TCP port to connect to Keystone API from admin network
#   Default to '5000'
#
# [*ks_cinder_password*]
#   (optional) Password used by Cinder to connect to Keystone API
#   Defaults to 'secrete'
#
# [*cinder_backends*]
#   (optionnal) Hash of the Cinder backends to enable
#   Example:
#   cinder_backends = {
#     'rbd' => {
#        'lowcost'  => { 'rbd_pool' => 'slow', 'rbd_user' => 'cinder', 'rbd_secret_uuid' => '123' },
#        'standard' => { 'rbd_pool' => 'normal', 'rbd_user' => 'cinder', 'rbd_secret_uuid' => '123' }
#     },
#     'netapp' => {
#        'premium' => { 'netapp_server_hostname' => 'netapp.host', 'netapp_login' => 'joe', 'netapp_password' => 'secret' }
#     }
#   }
#   Defaults to undef
#
# [*cinder_rbd_pool*]
#   (optional) Name of the Ceph pool which which store the cinder images
#   Defaults to 'volumes'
#
# [*cinder_rbd_user*]
#   (optional) User name used to acces to the cinder rbd pool
#   Defaults to 'cinder'
#
# [*cinder_rbd_secret_uuid*]
#   (optional) A required parameter to use cephx.
#   Defaults to false
#
# [*cinder_rbd_conf*]
#   (optional) Path to the ceph configuration file to use
#   Defaults to '/etc/ceph/ceph.conf'
#
# [*cinder_rbd_flatten_volume_from_snapshot*]
#   (optional) Enable flatten volumes created from snapshots.
#   Defaults to false
#
# [*cinder_rbd_max_clone_depth*]
#   (optional) Maximum number of nested clones that can be taken of a
#   volume before enforcing a flatten prior to next clone.
#   A value of zero disables cloning
#   Defaults to '5'
#
class cloud::volume::storage(

  $cinder_backends                         = undef,

  $ks_keystone_internal_proto              = 'http',
  $ks_keystone_internal_port               = '5000',
  $ks_keystone_internal_host               = '127.0.0.1',

  $ks_glance_internal_proto                = 'http',
  $ks_glance_api_internal_port             = '9292',
  $ks_glance_internal_host                 = '127.0.0.1',

  $ks_cinder_password                      = hiera('cinder::keystone::authtoken::password'),
  $ks_cinder_user                          = hiera('cinder::keystone::authtoken::username'),
  $ks_admin_tenant                         = hiera('cinder::keystone::authtoken::project_name'),

  $cinder_rbd_pool                         = 'volumes',
  $cinder_rbd_user                         = 'cinder',
  $cinder_rbd_secret_uuid                  = undef,
  $cinder_rbd_conf                         = '/etc/ceph/ceph.conf',
  $cinder_rbd_flatten_volume_from_snapshot = false,
  $cinder_rbd_max_clone_depth              = '5',
) {

  include ::cloud::volume

  include ::cinder::volume

  # Needed as dep. of cinder::type
  include ::cinder::client

  class { '::cinder::keystone::authtoken': }

  if $cinder_backends {

    if has_key($cinder_backends, 'rbd') {
      $rbd_backends = $cinder_backends['rbd']
      create_resources('::cloud::volume::backend::rbd', $rbd_backends)
    }
    else {
      $rbd_backends = { }
    }

    if has_key($cinder_backends, 'netapp') {
      $netapp_backends = $cinder_backends['netapp']
      create_resources('::cloud::volume::backend::netapp', $netapp_backends)
    }
    else {
      $netapp_backends = { }
    }

    if has_key($cinder_backends, 'iscsi') {
      $iscsi_backends = $cinder_backends['iscsi']
      create_resources('::cloud::volume::backend::iscsi', $iscsi_backends)
    }
    else {
      $iscsi_backends = { }
    }

    if has_key($cinder_backends, 'nfs') {
      $nfs_backends = $cinder_backends['nfs']
      create_resources('::cloud::volume::backend::nfs', $nfs_backends)
    }
    else {
      $nfs_backends = { }
    }

    class { '::cinder::backends':
      enabled_backends => keys(merge($rbd_backends, $netapp_backends, $iscsi_backends, $nfs_backends))
    }

    # Manage Volume types.
    # It allows to the end-user to choose from which backend he would like to provision a volume.
    # Cinder::Type requires keystone credentials

    # Make sure Cinder::Type is only run after cinder.conf is setup correctly (else resource prefetch will fail due to missing cinder.conf)
    Cinder_config<||> -> Cinder::Type <| |>
    
    # Cloud::Volume::Qos::Create requires keystone credentials
    Cloud::Volume::Qos::Create <| |> {
      os_tenant_name => $ks_admin_tenant,
      os_username    => $ks_cinder_user,
      os_password    => $ks_cinder_password,
      os_auth_url    => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_internal_port}/v3"
    }
    
    # Cloud::Volume::Qos::Associate requires keystone credentials
    Cloud::Volume::Qos::Associate <| |> {
      os_tenant_name => $ks_admin_tenant,
      os_username    => $ks_cinder_user,
      os_password    => $ks_cinder_password,
      os_auth_url    => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_internal_port}/v3"
    }
  }

  cinder_config {
    'DEFAULT/glance_api_servers':   value => "${ks_glance_internal_proto}://${ks_glance_internal_host}:${ks_glance_api_internal_port}";
    'DEFAULT/glance_host':          value => "${ks_glance_internal_host}";
  }

}
