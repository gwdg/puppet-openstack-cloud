#
class cloud::container::api(

  $ks_magnum_internal_port  = 9511,

  $auth_uri                 = 'http://127.0.0.1:5000/',
  $identity_uri             = 'http://127.0.0.1:35357/',

  $api_eth                  = '127.0.0.1',
  $ks_magnum_password       = 'magnumpassword',
){

  include ::cloud::container

  class { '::magnum::api':

    host           => $api_eth,
    port           => $ks_magnum_internal_port,

    auth_uri       => $auth_uri,
    identity_uri   => $identity_uri,

    admin_password => $ks_magnum_password,

    require        => Exec['/tmp/setup_magnum.sh']
  }

  @@haproxy::balancermember{"${::fqdn}-magnum_api":
    listening_service => 'magnum_api',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_magnum_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }
}
