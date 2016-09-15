#
class cloud::role::network-api inherits ::cloud::role::base {

    class { '::cloud::auth_file': }                     ->

    class { '::cloud::network::controller': }
}