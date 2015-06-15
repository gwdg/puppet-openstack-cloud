#
class cloud::role::compute inherits ::cloud::role::base {

    # NFS share is mounted directly in ::compute::hypervisor
    include ::nfs::client

    # Mount shared storage for live migrations
    Nfs::Client::Mount <<| nfstag == 'instances' |>> {  
        ensure      => 'mounted',
        options     => '_netdev,vers=3',
        owner       => 'nova',
        group       => 'nova',
        require     => User['nova'],
#        require     => Package['nova-common'],
    } 

#    ->

#    file { '/var/lib/nova/instances':
#      owner     => 'nova',
#      group     => 'nova',
#      recurse   => true,
#      notify    => Service['nova-compute'],
#    }

    # Use fixed uids / gids for nova user
    User['nova'] -> Package['nova-common']

    class { '::cloud': }                                ->
    class { '::cloud::network::l3': }                   ->
    class { '::cloud::network::metadata': }             ->
    class { '::cloud::compute::hypervisor': }           ->

    class { '::cloud::auth_file': }

}
