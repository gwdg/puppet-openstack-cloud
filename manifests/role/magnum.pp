#
class cloud::role::magnum inherits ::cloud::role::base {

    class { '::cloud::auth_file': }
}
