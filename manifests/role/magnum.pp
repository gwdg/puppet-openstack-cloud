#
class cloud::role::magnum inherits ::cloud::role::base {

    class { '::cloud::auth_file': }             -> 

    class { '::cloud::container::api': }        ->
    class { '::cloud::container::conductor': }

}
