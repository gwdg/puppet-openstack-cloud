class cloud::role::infra inherits ::cloud::role::base {

  class { '::cloud': }                      ->
  class { '::cloud::role::aptly': }         ->
  class { '::cloud::role::dns_forwarder': }
}
