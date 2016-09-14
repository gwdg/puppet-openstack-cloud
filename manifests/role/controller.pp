#
class cloud::role::controller inherits ::cloud::role::base {

    class { '::cloud::auth_file': }                     ->

    class { '::cloud::database::nosql::memcached': }    ->
    class { '::cloud::messaging': }                     ->
    class { '::cloud::identity': }                      ->

    class { '::cloud::volume::scheduler': }             ->
    class { '::cloud::volume::api': }                   ->

    class { '::cloud::compute::conductor': }            ->
    class { '::cloud::compute::cert': }                 ->
    class { '::cloud::compute::consoleauth': }          ->
    class { '::cloud::compute::consoleproxy': }         ->
    class { '::cloud::compute::api': }                  ->
    class { '::cloud::compute::scheduler': }            ->

    class { '::cloud::network::controller': }           ->
    class { '::cloud::dashboard': }                     ->

    class { '::cloud::orchestration::engine': }         ->
    class { '::cloud::orchestration::api': }            ->

    class { '::cloud::telemetry::tsdb': }                ->
    class { '::cloud::telemetry::api': }                 ->
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
