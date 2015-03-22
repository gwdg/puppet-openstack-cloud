class cloud::role::nfs inherits ::cloud::role::base {

  class { '::cloud': }                      ->
  class { '::cloud::profile::nfs_server': }
}
