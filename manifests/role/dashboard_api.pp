#
class cloud::role::dashboard_api inherits ::cloud::role::base {

    class { '::cloud::auth_file': }                     ->

    class { '::cloud::dashboard': }
}
