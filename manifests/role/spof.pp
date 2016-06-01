#
class cloud::role::spof inherits ::cloud::role::base {

    class { '::cloud::auth_file': }                     ->

    class { '::cloud::orchestration::engine': }         ->

    class { '::cloud::telemetry::centralagent': }       ->
    class { '::cloud::telemetry::alarmevaluator': }     ->
    class { '::cloud::telemetry::alarmnotifier': }      ->
    class { '::cloud::telemetry::collector': }          ->
    class { '::cloud::telemetry::notification': }

}
