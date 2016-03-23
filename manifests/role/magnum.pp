#
class cloud::role::magnum inherits ::cloud::role::base {

    class { '::cloud::container': } ->
    class { '::cloud::auth_file': } 
    
}
