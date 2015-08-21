#
class cloud::role::storage inherits ::cloud::role::base {

    # NFS setup (packages are also needed for cinder volume to mount nfs share)
    include ::nfs::client

    class { '::cloud': }                                ->

    # mariadb client is needed for cinder db sync
#    package {'mariadb-client-core-10.0': }              ->

    class { '::cloud::volume::storage': }               ->

    class { '::cloud::auth_file': }

}
