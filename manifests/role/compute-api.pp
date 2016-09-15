#
class cloud::role::compute-api inherits ::cloud::role::base {

    class { '::cloud::auth_file': }                     ->

    class { '::cloud::compute::conductor': }            ->
    class { '::cloud::compute::cert': }                 ->
    class { '::cloud::compute::consoleauth': }          ->
    class { '::cloud::compute::consoleproxy': }         ->
    class { '::cloud::compute::api': }                  ->
    class { '::cloud::compute::scheduler': }
}