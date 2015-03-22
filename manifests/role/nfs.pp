class cloud::role::nfs inherits ::cloud::role::base {

  class { '::cloud': }                      ->
  class { '::cloud::role::nfs_server': }
}
