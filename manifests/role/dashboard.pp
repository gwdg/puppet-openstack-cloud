#
class cloud::role::dashboard inherits ::cloud::role::base {

    class { '::cloud::auth_file': }                     ->
    
    class { '::cloud::dashboard': }
}
