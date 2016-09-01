#
class cloud::role::spof inherits ::cloud::role::base {

    class { '::cloud::auth_file': }                      ->

    class { '::cloud::telemetry::centralagent': }        ->

    class { '::cloud::telemetry::alarming::engine': }    ->
    class { '::cloud::telemetry::alarming::api': }       ->
    class { '::cloud::telemetry::alarming::evaluator': } ->
    class { '::cloud::telemetry::alarming::notifier': }  ->
    class { '::cloud::telemetry::alarming::listener': }  ->
    class { '::cloud::telemetry::alarming::client': }    ->
    
    class { '::cloud::telemetry::collector': }           ->
    class { '::cloud::telemetry::notification': }

}
