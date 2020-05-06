#
class cloud::role::orchestration_api inherits ::cloud::role::base {

    class { '::cloud::auth_file': }                     ->

    class { '::cloud::orchestration::engine': }         ->
    class { '::cloud::orchestration::api': }
}
