#
class cloud::role::memcached inherits ::cloud::role::base {

    class { '::cloud::auth_file': }                     ->

    class { '::cloud::database::nosql::memcached': }
}