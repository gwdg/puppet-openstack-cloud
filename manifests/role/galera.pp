class cloud::role::galera inherits ::cloud::role::base {

    class { '::cloud': }                        ->
    class { '::cloud::database::sql::mysql': }
}
