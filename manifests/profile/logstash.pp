#
class cloud::profile::logstash {

  $logstash_syslog_bind_ip = hiera('cloud::logging::server::logstash_syslog_bind_ip') 
  $logstash_syslog_port = hiera('cloud::logging::server::logstash_syslog_port') 

  #temporary until we have a logserver provision over puppet
  @@haproxy::balancermember{"${::fqdn}-logstash-syslog":
    listening_service => 'logstash_syslog',
    server_names      => $::hostname,
    ipaddresses       => $logstash_syslog_bind_ip,
    ports             => $logstash_syslog_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }
}