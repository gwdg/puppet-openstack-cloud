#
class cloud::role::storage_hlrn inherits ::cloud::role::base {

    class { '::cloud::auth_file': }                     ->

    class { '::cloud::volume::storage': }
}
