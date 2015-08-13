class cloud::role::aptly inherits ::cloud::role::base {

  class { '::cloud': }                          ->
  class { '::cloud::profile::aptly': }
}
