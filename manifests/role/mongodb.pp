#
class cloud::role::mongodb inherits ::cloud::role::base {

  class { '::mongodb::globals': }               ->
  class { '::mongodb::server': }                ->
  class { '::mongodb::client': }                ->
  class { '::mongodb::replset': }

}
