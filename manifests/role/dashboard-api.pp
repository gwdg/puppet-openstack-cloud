#
class cloud::role::dashboard-api inherits ::cloud::role::base {

    class { '::cloud::auth_file': }                     ->

    class { '::cloud::dashboard': }
}