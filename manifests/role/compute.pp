class cloud::role::compute inherits ::cloud::role::base {

    # NFS share is mounted directly in ::compute::hypervisor
    include ::nfs::client

    # Mount shared storage for live migrations
#    Nfs::Client::Mount <<| nfstag == 'instances' |>> {  
#        ensure  => 'mounted',
#        options => '_netdev,vers=3',
#        before  => Package['nova-common'],
#    }

    class { '::cloud': }                                ->
    class { '::cloud::network::l3': }                   ->
    class { '::cloud::compute::hypervisor': }           ->

    class { '::cloud::auth_file': }

}
