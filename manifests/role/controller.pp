#
class cloud::role::controller inherits ::cloud::role::base {

    # NFS setup
    include ::nfs::client

    # Mount nfs storage for glance images
    Nfs::Client::Mount <<| nfstag == 'images' |>> {
      ensure  => 'mounted',
      options => '_netdev,vers=3',
      require => Package['glance-api'],
    } ->

    file { '/var/lib/glance/images':
      owner     => 'glance', 
      group     => 'glance', 
      recurse   => true,
      notify    => Service['glance-api'],
    } 

    # Mount nfs storage for glance image-cache
    Nfs::Client::Mount <<| nfstag == 'image-cache' |>> {
        ensure  => 'mounted',
        options => '_netdev,vers=3',
        require => Package['glance-api'],
    } ->

    file { '/var/lib/glance/image-cache':
      owner     => 'glance',
      group     => 'glance',
      recurse   => true,
      notify    => Service['glance-api'],
    }

    class { '::cloud': }                                ->

    # mariadb client is needed for cinder / keystone db syncs
    package {'mariadb-client-core-10.0': }              ->

    class { '::cloud::database::nosql::memcached': }    ->
    class { '::cloud::messaging': }                     ->
    class { '::cloud::identity': }                      ->
    class { '::cloud::image::registry': }               ->
    class { '::cloud::image::api': }                    ->
    class { '::cloud::volume::api': }                   ->

    class { '::cloud::compute::conductor': }            ->
    class { '::cloud::compute::cert': }                 ->
    class { '::cloud::compute::consoleauth': }          ->
    class { '::cloud::compute::api': }                  ->
    class { '::cloud::compute::scheduler': }            ->

    class { '::cloud::network::controller': }           ->
    class { '::cloud::dashboard': }                     ->
    class { '::cloud::orchestration::api': }            ->

    class { '::cloud::auth_file': }

}
