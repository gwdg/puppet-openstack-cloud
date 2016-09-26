#
#
class cloud::container::conductor(


){
	include ::cloud::container

  class { '::magnum::conductor':
    require        => Exec['/tmp/setup_magnum.sh']
  }
}
