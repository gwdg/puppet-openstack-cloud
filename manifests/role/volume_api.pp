#
class cloud::role::volume_api inherits ::cloud::role::base {

    class { '::cloud::auth_file': }                     ->

    class { '::cloud::profile::memcache': }             ->
    
    class { '::cloud::volume::scheduler': }             ->
    class { '::cloud::volume::api': }
}
