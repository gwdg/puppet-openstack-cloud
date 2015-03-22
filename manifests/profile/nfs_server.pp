#
class cloud::profile::nfs_server {

  include ::nfs::server

  # Shared storage for live migrations
  nfs::server::export { '/storage/instances':
    nfstag  => 'instances',
    ensure  => 'mounted',
    server  => '10.1.200.6',
    clients => ['10.1.200.0/24(rw,insecure,async,no_root_squash)'],
    mount   => '/var/lib/nova/instances',
  }

  # Glance storage for images
  nfs::server::export { '/storage/images':
    nfstag  => 'images',
    ensure  => 'mounted',
    server  => '10.1.200.6',
    clients => ['10.1.200.0/24(rw,insecure,async,no_root_squash)'],
    mount   => '/var/lib/glance/images',
  }

  # Glance storage for image-cache
  nfs::server::export { '/storage/image-cache':
    nfstag  => 'image-cache',
    ensure  => 'mounted',
    server  => '10.1.200.6',
    clients => ['10.1.200.0/24(rw,insecure,async,no_root_squash)'],
    mount   => '/var/lib/glance/image-cache',
  }

  # Cinder volume storage
  nfs::server::export { '/storage/volumes':
    nfstag  => 'cinder',
    ensure  => 'mounted',
    server  => '10.1.200.6',
    clients => ['10.1.200.0/24(rw,insecure,async,no_root_squash)'],
#   mount   => '/var/lib/nova/instances',
  }
}
