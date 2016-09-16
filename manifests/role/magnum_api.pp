#
class cloud::role::magnum_api inherits ::cloud::role::base {

    class { '::cloud::auth_file': }             -> 

    class { '::cloud::profile::memcache': }     ->
    
    class { '::cloud::container::api': }        ->
    class { '::cloud::container::conductor': }

}
