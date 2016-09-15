#
class cloud::role::indentity-api inherits ::cloud::role::base {

    class { '::cloud::auth_file': }                     ->

    class { '::cloud::identity': }
}