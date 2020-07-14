#
class cloud::role::storage-hlrn inherits ::cloud::role::base {

    class { '::cloud::auth_file': }                     ->

    class { '::cloud::volume::storage': }
}
