#
class cloud::role::network inherits ::cloud::role::base {

    class { '::cloud::auth_file': }                     ->

    class { '::cloud::network::l3': }                   ->
    class { '::cloud::network::dhcp': }                 ->
    class { '::cloud::network::metadata': }             ->
    class { '::cloud::network::lbaas': }

}
