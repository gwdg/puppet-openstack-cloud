#
class cloud::role::logging inherits ::cloud::role::base {

	$kibana_bind_ip = hiera('cloud::logging::server::kibana_bind_ip')
	$kibana_port = hiera('cloud::logging::server::kibana_port')

	#temporary until we have a logserver provision over puppet
	@@haproxy::balancermember{"${::fqdn}-kibana":
		listening_service => 'kibana',
		server_names      => $::hostname,
		ipaddresses       => $kibana_bind_ip,
		ports             => $kibana_port,
		options           => 'check inter 2000 rise 2 fall 5'
	}

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