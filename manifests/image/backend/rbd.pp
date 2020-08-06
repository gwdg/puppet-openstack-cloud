#
# Configure RBD backend for Glance
#

define cloud::image::backend::rbd (
  $rbd_pool,
  $rbd_user,
  $rbd_key,
) {

  # Handle ceph.conf + ceph packages
  include ::cloud::storage::rbd

  # Configure Glance rbd backend
  class { '::glance::backend::rbd':
    rbd_store_user            => $rbd_user,
    rbd_store_pool            => $rbd_pool,
    rbd_store_chunk_size      => 8,
#    rados_connect_timeout     => 0,
  }

  # Set client key for cephx
  ceph::key { "client.${rbd_user}":
    secret          => $rbd_key,
    user            => 'glance',
    group           => 'glance',
    keyring_path    => "/etc/ceph/ceph.client.${rbd_user}.keyring",
    notify          => Service['glance-api','glance-registry'],
  }
}

