class cloud::role::spof inherits ::cloud::role::base {

    class { '::cloud': }                                ->

    # mariadb client is needed for heat db syncs
#    package {'mariadb-client-core-10.0': }              ->

    class { '::cloud::orchestration::engine': }         ->

    class { '::cloud::telemetry::centralagent': }       ->
    class { '::cloud::telemetry::alarmevaluator': }     ->
    class { '::cloud::telemetry::alarmnotifier': }      ->
    class { '::cloud::telemetry::collector': }          ->
    class { '::cloud::telemetry::notification': }       ->

    class { '::cloud::auth_file': }
}
