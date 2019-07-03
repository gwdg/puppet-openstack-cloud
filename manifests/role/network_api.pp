#
class cloud::role::network_api inherits ::cloud::role::base {

    class { '::cloud::auth_file': }                     ->

    class { '::cloud::network::controller': }
}
