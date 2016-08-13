class cloud::role::mongodb inherits ::cloud::role::base {

  class { '::mongodb::globals': }               ->
  class { '::mongodb::server': }                ->
  class { '::mongodb::client': }                ->
  class { '::mongodb::replset': }

  # Fix mongodb v3.2.8 
  file { '/lib/systemd/system/mongod.service':
    content => file('cloud/patches/mongodb_3.2.8_fix_no_systemd_service_file.txt'),
    before  => Class['mongodb::server::service'],
    require => Class['mongodb::server::install']
  }
}
