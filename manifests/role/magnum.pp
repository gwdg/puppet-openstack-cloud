#
class cloud::role::magnum inherits ::cloud::role::base {

    class { '::cloud::container::api': } ->
    class { '::cloud::container::conductor': } ->

    class { '::cloud::auth_file': } 
}
