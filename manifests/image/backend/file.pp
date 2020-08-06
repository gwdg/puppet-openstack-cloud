#
# Configure file backend for Glance (with nfs support)
#

define cloud::image::backend::file (
  $images_location          = '/var/lib/glance/images',
  $nfs_images_server        = undef,
  $nfs_images_share         = undef,
  $nfs_images_share_options = '_netdev,vers=3',
) {

  include ::nfs::client

  nfs::client::mount { "${images_location}":

    mount     => "${images_location}",

    server    => $nfs_images_server,
    share     => $nfs_images_share,
    options   => $nfs_images_share_options,

    owner     => 'glance',
    group     => 'glance',

    require   => Package['glance-api'],
  }

  class { '::glance::backend::file':
    filesystem_store_datadir => $images_location
  }
}

