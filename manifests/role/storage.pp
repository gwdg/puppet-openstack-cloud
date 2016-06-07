#
class cloud::role::storage inherits ::cloud::role::base {

    # NFS setup (packages are also needed for cinder volume to mount nfs share)
    include ::nfs::client

    class { '::cloud::auth_file': }                     ->

    class { '::cloud::storage::rbd': }                  ->
    class { '::cloud::volume::storage': }               ->

    class { '::cloud::image::registry': }               ->
    class { '::cloud::image::api': }
}
