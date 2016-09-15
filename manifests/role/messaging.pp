#
class cloud::role::messaging inherits ::cloud::role::base {

    class { '::cloud::auth_file': }                     ->

    class { '::cloud::messaging': } 
}