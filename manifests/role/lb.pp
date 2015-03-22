class cloud::role::lb inherits ::cloud::role::base {

    class { '::cloud': }                    ->
    class { '::cloud::loadbalancer': }
}
