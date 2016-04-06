#
#
class cloud::container::api(
  $ks_magnum_internal_port    = 9511,
  $ks_keystone_internal_host  = '127.0.0.1',
  $ks_keystone_internal_port  = '5000',
  $ks_keystone_internal_proto = 'http',
  $ks_keystone_admin_port     = '35357',
  $api_eth                    = '127.0.0.1',
  $ks_magnum_password         = 'magnumpassword',
){

	include 'cloud::container'

	class { 'magnum::api':
		admin_password => $ks_magnum_password,
		host           => $api_eth,
    	auth_uri       => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_internal_port}/v2.0",
  		identity_uri   => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_admin_port}",
    	port           => $ks_magnum_internal_port,
  	}

	@@haproxy::balancermember{"${::fqdn}-magnum_api":
    listening_service => 'magnum_api',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_magnum_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }
}