#
class cloud::role::orchestration-api inherits ::cloud::role::base {

    class { '::cloud::auth_file': }                     ->

    class { '::cloud::orchestration::engine': }         ->
    class { '::cloud::orchestration::api': }
}