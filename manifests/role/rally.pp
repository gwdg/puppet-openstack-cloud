class cloud::role::rally inherits ::cloud::role::base {

    class { '::cloud': }                ->
    class { '::cloud::auth_file': }
}
