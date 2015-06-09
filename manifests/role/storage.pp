class cloud::role::storage inherits ::cloud::role::base {

    # NFS setup (packages are also needed for cinder volume to mount nfs share)
    include ::nfs::client

    # Mount nfs storage for glance images
#    Nfs::Client::Mount <<| nfstag == 'images' |>> {
#        ensure  => 'mounted',
#        options => '_netdev,vers=3',
#        require => Package['glance-api'],
#    }

    # Mount nfs storage for glance image-cache
#    Nfs::Client::Mount <<| nfstag == 'image-cache' |>> {
#        ensure  => 'mounted',
#        options => '_netdev,vers=3',
#        require => Package['glance-api'],
#    }

    class { '::cloud': }                                ->

    # mariadb client is needed for cinder db sync
#    package {'mariadb-client-core-10.0': }              ->

    class { '::cloud::volume::storage': }               ->

    class { '::cloud::auth_file': }

}
