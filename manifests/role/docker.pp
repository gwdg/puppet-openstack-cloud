#
class cloud::role::docker inherits ::cloud::role::base {

    # Use fixed uids / gids for nova user
    User['nova'] -> Package['nova-common']

    class { '::cloud::auth_file': }                     ->

    class { '::cloud::network::l3': }                   ->
    class { '::cloud::network::metadata': }             ->
    class { '::cloud::compute::hypervisor': }           ->
    class { '::cloud::profile::docker': }               ->
    class { '::cloud::profile::nova_docker': }


}
