#
class cloud::role::identity_api inherits ::cloud::role::base {

    class { '::cloud::auth_file': }                     ->
    
    class { '::cloud::identity': }                      ->

    class { '::cloud::identity::openidc': }
}
