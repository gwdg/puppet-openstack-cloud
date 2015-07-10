#
class cloud::role::logging inherits ::cloud::role::base {

	class { '::cloud': }                          ->
  	class { '::cloud::profile::logstash': }       ->
  	class { '::cloud::profile::kibana': }

}