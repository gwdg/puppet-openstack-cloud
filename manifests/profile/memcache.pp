#
class cloud::profile::memcache {

  # Make sure Memcache Python module is available (will be made obsolete with use of oslo.cache puppet module)
  include ::oslo::params
  ensure_packages('python-memcache', {
    ensure => present,
    name   => $::oslo::params::python_memcache_package_name,
    tag    => ['openstack'],
  })
}