#
class cloud::role::dashboard_api inherits ::cloud::role::base {

    class { '::cloud::auth_file': }                     ->

    class { '::cloud::profile::memcache': }             ->
    
    class { '::cloud::dashboard': }
}
