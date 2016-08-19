#
class cloud::profile::influxdb (
  $api_eth        = '127.0.0.1',
  $internal_port  = 8086,
) {

  #temporary until we have a influxdb provision over puppet
  @@haproxy::balancermember{"${::fqdn}-influxdb":
    listening_service => 'influxdb',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }
  
}

