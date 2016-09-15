#
class cloud::role::volume-api inherits ::cloud::role::base {

    class { '::cloud::auth_file': }                     ->

    class { '::cloud::volume::scheduler': }             ->
    class { '::cloud::volume::api': }
}