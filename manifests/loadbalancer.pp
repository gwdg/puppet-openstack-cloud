#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: cloud::loadbalancer
#
# Install Load-Balancer node (HAproxy + Keepalived)
#
# === Parameters:
#
# [*keepalived_vrrp_interface*]
#  (optional) Networking interface to bind the vrrp traffic.
#  Defaults to false (disabled)
#
# [*keepalived_public_interface*]
#   (optional) Networking interface to bind the VIP connected to public network.
#   Defaults to 'eth0'
#
# [*keepalived_internal_interface*]
#   (optional) Networking interface to bind the VIP connected to internal network.
#   keepalived_internal_ipvs should be configured to enable the internal VIP.
#   Defaults to 'eth1'
#
# [*keepalived_public_ipvs*]
#   (optional) IP address of the VIP connected to public network.
#   Should be an array.
#   Defaults to ['127.0.0.1']
#
# [*keepalived_internal_ipvs*]
#   (optional) IP address of the VIP connected to internal network.
#   Should be an array.
#   Defaults to false (disabled)
#
# [*keepalived_public_id*]
#   (optional) used for the keepalived public virtual_router_id.
#   Should be numeric.
#   Defaults to '1'
#
# [*keepalived_internal_id*]
#   (optional) used for the keepalived internal virtual_router_id.
#   Should be numeric.
#   Defaults to '2'
#
# [*keepalived_auth_type*]
#   (optional) Authentication method.
#   Supported methods are simple Passwd (PASS) or IPSEC AH (AH).
#   Defaults to undef
#
# [*keepalived_auth_pass*]
#   (optional) Authentication password.
#   Password string (up to 8 characters).
#   Defaults to undef
#
# [*swift_api*]
#   (optional) Enable or not Swift public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*ceilometer_api*]
#   (optional) Enable or not Ceilometer public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*cinder_api*]
#   (optional) Enable or not Cinder public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*glance_api*]
#   (optional) Enable or not Glance API public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*glance_registry*]
#   (optional) Enable or not Glance Registry public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*neutron_api*]
#   (optional) Enable or not Neutron public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*heat_api*]
#   (optional) Enable or not Heat public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*heat_cfn_api*]
#   (optional) Enable or not Heat CFN public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*heat_cloudwatch_api*]
#   (optional) Enable or not Heat Cloudwatch public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*nova_api*]
#   (optional) Enable or not Nova public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*trove_api*]
#   (optional) Enable or not Trove public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*horizon*]
#   (optional) Enable or not Horizon public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*horizon_ssl*]
#   (optional) Enable or not Horizon SSL public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*spice*]
#   (optional) Enable or not spice binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure.
#   Defaults to false
#
# [*novnc*]
#   (optional) Enable or not novnc binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure.
#   Defaults to true
#
# [*elasticsearch*]
#   (optional) Enable or not ElasticSearch binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure.
#   Defaults to true
#
# [*kibana*]
#   (optional) Enable or not kibana binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure.
#   Defaults to true
#
# [*redis*]
#   (optional) Enable or not redis binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure.
#   Defaults to true
#
# [*metadata_api*]
#   (optional) Enable or not Metadata public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*keystone_api*]
#   (optional) Enable or not Keystone public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*rabbitmq*]
#   (optional) Enable or not RabbitMQ binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure.
#   Defaults to false
#
# [*sensu_dashboard*]
#   (optional) Enable or not sensu_dashboard binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure.
#   Defaults to true
#
# [*sensu_api*]
#   (optional) Enable or not sensu_api binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure.
#   Defaults to true
#
# [*keystone_api_admin*]
#   (optional) Enable or not Keystone admin binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*haproxy_auth*]
#  (optional) The HTTP sytle basic credentials (using login:password form)
#  Defaults to 'admin:changeme'
#
# [*haproxy_global_options*]
#  (optional) The haproxy global options
#  Defaults to {}
#
# [*haproxy_defaults__options*]
#  (optional) The haproxy defaults options
#  Defaults to {}
#
# [*keepalived_state*]
#  (optional) TODO
#  Defaults to 'BACKUP'
#
# [*keepalived_priority*]
#  (optional) TODO
#  Defaults to '50'
#
# [*ceilometer_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*cinder_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*glance_api_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*glance_registry_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*heat_cfn_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*heat_cloudwatch_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*heat_api_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*keystone_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*keystone_admin_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*metadata_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*neutron_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*nova_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*trove_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*swift_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*spice_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*novnc_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*horizon_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*horizon_ssl_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*rabbitmq_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*elasticsearch_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*kibana_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*sensu_dashboard_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*sensu_api_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*redis_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*galera_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*ks_ceilometer_public_port*]
#   (optional) TCP port to connect to Ceilometer API from public network
#   Defaults to '8777'
#
# [*ks_cinder_public_port*]
#   (optional) TCP port to connect to Cinder API from public network
#   Defaults to '8776'
#
# [*ks_glance_api_public_port*]
#   (optional) TCP port to connect to Glance API from public network
#   Defaults to '9292'
#
# [*ks_glance_registry_internal_port*]
#   (optional) TCP port to connect to Glance API from public network
#   Defaults to '9191'
#
# [*ks_heat_cfn_public_port*]
#   (optional) TCP port to connect to Heat API from public network
#   Defaults to '8000'
#
# [*ks_heat_cloudwatch_public_port*]
#   (optional) TCP port to connect to Heat API from public network
#   Defaults to '8003'
#
# [*ks_heat_public_port*]
#   (optional) TCP port to connect to Heat API from public network
#   Defaults to '8004'
#
# [*ks_keystone_admin_port*]
#   (optional) TCP port to connect to Keystone Admin API from public network
#   Defaults to '35357'
#
# [*ks_keystone_public_port*]
#   (optional) TCP port to connect to Keystone API from public network
#   Defaults to '5000'
#
# [*ks_metadata_public_port*]
#   (optional) TCP port to connect to Keystone metadata API from public network
#   Defaults to '8775'
#
# [*ks_swift_public_port*]
#   (optional) TCP port to connect to Swift API from public network
#   Defaults to '8080'
#
# [*ks_trove_public_port*]
#   (optional) TCP port to connect to Trove API from public network
#   Defaults to '8779'
#
# [*ks_nova_public_port*]
#   (optional) TCP port to connect to Nova API from public network
#   Defaults to '8774'
#
# [*ks_neutron_public_port*]
#   (optional) TCP port to connect to Neutron API from public network
#   Defaults to '9696'
#
# [*horizon_port*]
#   (optional) Port used to connect to OpenStack Dashboard
#   Defaults to '80'
#
# [*horizon_ssl_port*]
#   (optional) Port used to connect to OpenStack Dashboard using SSL
#   Defaults to '443'
#
# [*spice_port*]
#   (optional) TCP port to connect to Nova spicehtmlproxy service.
#   Defaults to '6082'
#
# [*novnc_port*]
#   (optional) TCP port to connect to Nova vncproxy service.
#   Defaults to '6080'
#
# [*rabbitmq_port*]
#   (optional) Port of RabbitMQ service.
#   Defaults to '5672'
#
# [*elasticsearch_port*]
#   (optional) Port of ElasticSearch service.
#   Defaults to '9200'
#
# [*kibana_port*]
#   (optional) Port of Kibana service.
#   Defaults to '8300'
# [*sensu_dashboard_port*]
#   (optional) Port of Sensu Dashboard service.
#   Defaults to '3000'
#
# [*sensu_api_port*]
#   (optional) Port of Sensu API service.
#   Defaults to '4568'
#
# [*redis_port*]
#   (optional) Port of redis service.
#   Defaults to '6379'
#
# [*galera_timeout*]
#   (optional) Timeout for galera connections
#   Defaults to '90m'.
#   Note: when changing this parameter you should also change the
#         *_db_idle_timeout for all services to be a little less
#         than this timeout.
#
# [*galera_connections*]
#   (optional) An integer that specifies the maxconn for MySQL
#   Defaults to '4096'
#
# [*api_timeout*]
#   (optional) Timeout for API services connections
#   Defaults to '90m'.
#
# [*vip_public_ip*]
#  (optional) Array or string for public VIP
#  Should be part of keepalived_public_ips
#  Defaults to '127.0.0.2'
#
# [*vip_internal_ip*]
#  (optional) Array or string for internal VIP
#  Should be part of keepalived_internal_ips
#  Defaults to false
#
# [*vip_monitor_ip*]
#  (optional) Array or string for monitor VIP
#  Defaults to false
#
# [*galera_ip*]
#  (optional) An array of Galera IP
#  Defaults to ['127.0.0.1']
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::loadbalancer(

  $enable_swift_api                 = false,
  $enable_ceilometer_api            = false,
  $enable_cinder_api                = false,
  $enable_glance_api                = false,
  $enable_glance_registry           = false,
  $enable_neutron_api               = false,
  $enable_magnum_api                = false,
  $enable_heat_api                  = false,
  $enable_heat_cfn_api              = false,
  $enable_heat_cloudwatch_api       = false,
  $enable_nova_api                  = false,
  $enable_metadata_api              = false,
  $enable_keystone_api              = false,
  $enable_keystone_api_admin        = false,
  $enable_trove_api                 = false,
  $enable_horizon                   = false,
  $enable_horizon_ssl               = false,
  $enable_rabbitmq                  = false,
  $enable_rabbitmq_management       = false,
  $enable_spice                     = false,
  $enable_novnc                     = false,
  $enable_elasticsearch             = false,
  $enable_kibana                    = false,
  $enable_logstash_syslog           = false,
  $enable_sensu_dashboard           = false,
  $enable_sensu_api                 = false,
  $enable_redis                     = false,
  $enable_galera                    = false,
  $enable_galera_readonly           = false,

  $haproxy_auth                     = 'admin:changeme',

  $keepalived_state                 = 'BACKUP',
  $keepalived_priority              = '50',
  $keepalived_vrrp_interface        = false,
  $keepalived_public_interface      = 'eth0',
  $keepalived_public_ipvs           = ['127.0.0.1'],
  $keepalived_public_id             = '1',
  $keepalived_internal_interface    = 'eth1',
  $keepalived_internal_ipvs         = false,
  $keepalived_internal_id           = '2',
  $keepalived_auth_type             = false,
  $keepalived_auth_pass             = false,

  $ceilometer_options               = {},
  $cinder_options                   = {},
  $glance_api_options               = {},
  $glance_registry_options          = {},
  $magnum_api_options               = {},
  $heat_cfn_options                 = {},
  $heat_cloudwatch_options          = {},
  $heat_api_options                 = {},
  $keystone_options                 = {},
  $keystone_admin_options           = {},
  $metadata_options                 = {},
  $neutron_options                  = {},
  $nova_options                     = {},
  $trove_options                    = {},
  $swift_options                    = {},
  $spice_options                    = {},
  $novnc_options                    = {},
  $horizon_options                  = {},
  $horizon_ssl_options              = {},
  $rabbitmq_options                 = {},
  $galera_options                   = {},
  $galera_readonly_options          = {},
  $elasticsearch_options            = {},
  $kibana_options                   = {},
  $logstash_syslog_options          = {},
  $sensu_dashboard_options          = {},
  $sensu_api_options                = {},
  $redis_options                    = {},

  $ks_ceilometer_public_port        = 8777,
  $ks_cinder_public_port            = 8776,
  $ks_glance_api_public_port        = 9292,
  $ks_glance_registry_internal_port = 9191,
  $ks_magnum_public_port            = 9511,
  $ks_heat_cfn_public_port          = 8000,
  $ks_heat_cloudwatch_public_port   = 8003,
  $ks_heat_public_port              = 8004,
  $ks_keystone_admin_port           = 35357,
  $ks_keystone_public_port          = 5000,
  $ks_metadata_public_port          = 8775,
  $ks_neutron_public_port           = 9696,
  $ks_nova_public_port              = 8774,
  $ks_swift_public_port             = 8080,
  $ks_trove_public_port             = 8779,
  $rabbitmq_port                    = 5672,
  $galera_port                      = 3306,
  $galera_readonly_port             = 3307,

  $horizon_port                     = 80,
  $horizon_ssl_port                 = 443,
  $spice_port                       = 6082,
  $novnc_port                       = 6080,
  $elasticsearch_port               = 9200,
  $kibana_port                      = 8300,
  $logstash_syslog_port             = 514,
  $sensu_dashboard_port             = 3000,
  $sensu_api_port                   = 4568,
  $redis_port                       = 6379,
  $galera_timeout                   = '1m',
  $galera_connections               = '4096',
  $api_timeout                      = '1m',

  $vip_public_ip                    = false,
  $vip_public_network               = false,
  $vip_public_gateway               = false,

  $vip_internal_ip                  = false,
  $vip_internal_network             = false,
  $vip_internal_gateway             = false,

  $vip_monitor_ip                   = false,
  $galera_ip                        = ['127.0.0.1'],
  $firewall_settings                = {},

  # New settings
  $haproxy_ensure                   = 'present',
  $haproxy_global_options           = {},
  $haproxy_defaults_options         = {},

  $keepalived_preempt_delay         = undef,
  $rabbitmq_management_port         = 15672,

  $haproxy_certs                    = 'api.dev.cloud.gwdg.de_20150716_all.pem',
){

  include cloud::params
  include haproxy::params
  include cloud::network::contrail::haproxy

  $common_tcp_options = {
    'mode'           => 'tcp',
    'option'         => ['tcpka', 'tcplog', 'forwardfor'],
    'balance'        => 'source',
    'timeout server' => $api_timeout,
    'timeout client' => $api_timeout,
  }

  $common_http_options = {
    'mode'           => 'http',
    'option'         => ['http-server-close', 'httplog', 'forwardfor'],
    'balance'        => 'source',

    # ssl specific
    'reqadd'         => 'X-Forwarded-Proto:\ https if { ssl_fc }',

    'timeout server' => $api_timeout,
    'timeout client' => $api_timeout,
  }

  # Deploy certs
  file { '/etc/haproxy/ssl':
    ensure      => 'directory',
    owner       => 'haproxy',
    group       => 'haproxy',
    mode        => '700',
    require     => Package['haproxy'],
  } ->
  file { '/etc/haproxy/ssl/certs.pem':
    owner       => 'haproxy',
    group       => 'haproxy',
    mode        => '600',
    source      => "puppet:///modules/cloud/secrets/${haproxy_certs}"
  }

  # Make sure it is deployed before the rest runs
  File['/etc/haproxy/ssl/certs.pem'] -> Haproxy::Listen <||>

  if $keepalived_vrrp_interface {
    $keepalived_vrrp_interface_real = $keepalived_vrrp_interface
  } else {
    $keepalived_vrrp_interface_real = $keepalived_public_interface
  }

  # Fail if OpenStack and Galera VIP are  not in the VIP list
  if $vip_public_ip and !(member(any2array($keepalived_public_ipvs), $vip_public_ip)) {
    fail('vip_public_ip should be part of keepalived_public_ipvs.')
  }
  if $vip_internal_ip and !(member(any2array($keepalived_internal_ipvs),$vip_internal_ip)) {
    fail('vip_internal_ip should be part of keepalived_internal_ipvs.')
  }
  if $galera_ip and !((member(any2array($keepalived_public_ipvs),$galera_ip)) or (member(any2array($keepalived_internal_ipvs),$galera_ip))) {
    fail('galera_ip should be part of keepalived_public_ipvs or keepalived_internal_ipvs.')
  }

  # Merge haproxy global / defaults options with param defaults from haproxy class, so that distro specific stuff is correctly taken into account
  $haproxy_global_options_real      = merge($::haproxy::params::global_options,   $haproxy_global_options)
  $haproxy_defaults_options_real    = merge($::haproxy::params::defaults_options, $haproxy_defaults_options)

  # Ensure Keepalived is started before HAproxy to avoid binding errors.
  class { 'keepalived': } ->
  class { 'haproxy':
    service_manage      => true,
    package_ensure      => $haproxy_ensure,
    global_options      => $haproxy_global_options_real,
    defaults_options    => $haproxy_defaults_options_real,
  }

  keepalived::vrrp::script { 'haproxy':
#    name_is_process => $::cloud::params::keepalived_name_is_process,
#    script          => $::cloud::params::keepalived_vrrp_script,
    script              => 'killall -0 haproxy',
    interval            => 2,
    weight              => 2,
  }

  keepalived::vrrp::instance { $keepalived_public_id:
    interface               => $keepalived_vrrp_interface_real,
    virtual_ipaddress       => $keepalived_public_ipvs,
    virtual_router_id       => $keepalived_public_id,
    state                   => $keepalived_state,
    track_script            => ['haproxy'],
    priority                => $keepalived_priority,
    preempt_delay           => $keepalived_preempt_delay,
    auth_type               => $keepalived_auth_type,
    auth_pass               => $keepalived_auth_pass,
    notify_script_master    => '/etc/init.d/haproxy start',
  }

  # If using an internal VIP, allow to use a dedicated interface for VRRP traffic.
  # First we check if internal binding is enabled
  if $keepalived_internal_ipvs {

    # If vagrant environment setup appropriate routing on lbs for external access via keepalived notification scripts
    $keepalived_notify = '/etc/keepalived/keepalived_setup_routing.sh'

    if ! $::cloud::production {

        # Vagrant setup
        $routing_internal   = true
        $routing_public     = true

    } else {

        # Production setup
        $routing_internal   = false
        $routing_public     = true
    }

    file { $keepalived_notify:                                                                                                                                                                          
      content   => template('cloud/loadbalancer/keepalived_setup_routing.sh'),
      require   => Package['keepalived'],
      mode      => '0775',
      before    => Keepalived::Vrrp::Instance[$keepalived_internal_id],
    }

    # Then we validate this is not the same as public binding
    if !empty(difference(any2array($keepalived_internal_ipvs), any2array($keepalived_public_ipvs))) {
      if ! $keepalived_vrrp_interface {
        $keepalived_vrrp_interface_internal = $keepalived_internal_interface
      } else {
        $keepalived_vrrp_interface_internal = $keepalived_vrrp_interface
      }
      keepalived::vrrp::instance { $keepalived_internal_id:
        interface               => $keepalived_vrrp_interface_internal,
        virtual_ipaddress       => $keepalived_internal_ipvs,
        virtual_router_id       => $keepalived_internal_id,
        state                   => $keepalived_state,
        track_script            => ['haproxy'],
        priority                => $keepalived_priority,
        preempt_delay           => $keepalived_preempt_delay,
        auth_type               => $keepalived_auth_type,
        auth_pass               => $keepalived_auth_pass,
        notify_script_master    => '/etc/init.d/haproxy start',
        notify_script           => $keepalived_notify,
      }
    }
  }

  logrotate::rule { 'haproxy':
    path          => '/var/log/haproxy.log',
    rotate        => 7,
    rotate_every  => 'day',
    missingok     => true,
    ifempty       => false,
    delaycompress => true,
    compress      => true,
  }

  if $vip_monitor_ip {
    $vip_monitor_ip_real = $vip_monitor_ip
  } else {
    $vip_monitor_ip_real = $vip_public_ip
  }

  haproxy::listen { 'monitor':
    ipaddress => $vip_monitor_ip_real,
    ports     => '10300',
    options   => {
      'mode'        => 'http',
      'monitor-uri' => '/status',
      'stats'       => ['enable','uri     /admin','realm   Haproxy\ Statistics',"auth    ${haproxy_auth}", 'refresh 5s' ],
      ''            => template('cloud/loadbalancer/monitor.erb'),
    }
  }

  # HAproxy bindings

  cloud::loadbalancer::bind_api { 'keystone_api':
    enable              => $enable_keystone_api,
    public_access       => true,
    port                => $ks_keystone_public_port,
    options             => merge($common_http_options, $keystone_options),
  }

  cloud::loadbalancer::bind_api { 'keystone_api_admin':
    enable              => $enable_keystone_api_admin,
    public_access       => true,
    port                => $ks_keystone_admin_port,
    options             => merge($common_http_options, $keystone_admin_options),
  }

  cloud::loadbalancer::bind_api { 'nova_api':
    enable              => $enable_nova_api,
    public_access       => true,
    port                => $ks_nova_public_port,
    options             => merge($common_http_options, $nova_options),
  }

  cloud::loadbalancer::bind_api { 'metadata_api':
    enable              => $enable_metadata_api,
    port                => $ks_metadata_public_port,
    options             => merge($common_http_options, $metadata_options),
  }

  cloud::loadbalancer::bind_api { 'sensu_dashboard':
    enable              => $enable_sensu_dashboard,
    port                => $sensu_dashboard_port,
    options             => merge($common_http_options, $sensu_dashboard_options),
  }

  cloud::loadbalancer::bind_api { 'sensu_api':
    enable              => $enable_sensu_api,
    port                => $sensu_api_port,
    options             => merge($common_http_options,
                                {
                                    'balance' => 'source',
                                    'rspadd'  => ['Access-Control-Allow-Origin:\ *', 'Access-Control-Allow-Headers:\ origin,\ x-requested-with,\ content-type', 'Access-Control-Allow-Methods:\ PUT,\ GET,\ POST,\ DELETE,\ OPTIONS'],
                                },
                                $sensu_api_options),
  }

  cloud::loadbalancer::bind_api { 'spice':
    enable              => $enable_spice,
    public_access       => true,
    port                => $spice_port,
    options             => merge($common_http_options, $spice_options),
  }

  cloud::loadbalancer::bind_api { 'novnc':
    enable              => $enable_novnc,
    public_access       => true,
    port                => $novnc_port,
    options             => merge($common_http_options, $novnc_options),
  }

  cloud::loadbalancer::bind_api { 'rabbitmq':
    enable              => $enable_rabbitmq,
    port                => $rabbitmq_port,
    options             => merge($common_tcp_options, 
                                {
                                    'option'          => ['tcpka', 'tcplog', 'forwardfor', 'clitcpka'],
                                    # Timeouts must be > /proc/sys/net/ipv4/tcp_keepalive_time (= 2h on Ubuntu 14.04), to allow for client tcp to send keepalives
                                    'timeout server'  => '180m',
                                    'timeout client'  => '180m',
                                    'timeout server'  => $api_timeout,
                                    'timeout client'  => $api_timeout,
                                    'balance'         => 'roundrobin',
                                },
                                $rabbitmq_options),
  }

  cloud::loadbalancer::bind_api { 'rabbitmq_management':
    enable              => $enable_rabbitmq_management,
    port                => $rabbitmq_management_port,
    options             => merge($common_http_options, $rabbitmq_management_options),
  }

  cloud::loadbalancer::bind_api { 'trove_api':
    enable              => $enable_trove_api,
    public_access       => true,
    port                => $ks_trove_public_port,
    options             => merge($common_http_options, $trove_options),
  }

  cloud::loadbalancer::bind_api { 'glance_api':
    enable              => $enable_glance_api,
    public_access       => true,
    port                => $ks_glance_api_public_port,
    options             => merge($common_http_options, $glance_api_options),
  }

  cloud::loadbalancer::bind_api { 'glance_registry':
    enable              => $enable_glance_registry,
    public_access       => true,
    port                => $ks_glance_registry_internal_port,
    options             => merge($common_http_options, $glance_registry_options),
  }

  cloud::loadbalancer::bind_api { 'neutron_api':
    enable              => $enable_neutron_api,
    public_access       => true,
    port                => $ks_neutron_public_port,
    options             => merge($common_http_options, $neutron_options),
  }

  cloud::loadbalancer::bind_api { 'cinder_api':
    enable              => $enable_cinder_api,
    public_access       => true,
    port                => $ks_cinder_public_port,
    options             => merge($common_http_options, $cinder_options),
  }

  cloud::loadbalancer::bind_api { 'ceilometer_api':
    enable              => $enable_ceilometer_api,
    public_access       => true,
    port                => $ks_ceilometer_public_port,
    options             => merge($common_http_options, $ceilometer_options),
  }

  cloud::loadbalancer::bind_api { 'magnum_api':
    enable              => $enable_magnum_api,
    public_access       => true,
    port                => $ks_magnum_public_port,
    options             => merge($common_http_options, $magnum_api_options),
  }  

  cloud::loadbalancer::bind_api { 'heat_api':
    enable              => $enable_heat_api,
    public_access       => true,
    port                => $ks_heat_public_port,
    options             => merge($common_http_options, $heat_api_options),
  }

  cloud::loadbalancer::bind_api { 'heat_cfn_api':
    enable              => $enable_heat_cfn_api,
    public_access       => true,
    port                => $ks_heat_cfn_public_port,
    options             => merge($common_http_options, $heat_cfn_options),
  }

  cloud::loadbalancer::bind_api { 'heat_cloudwatch_api':
    enable              => $enable_heat_cloudwatch_api,
    public_access       => true,
    port                => $ks_heat_cloudwatch_public_port,
    options             => merge($common_http_options, $heat_cloudwatch_options),
  }

  cloud::loadbalancer::bind_api { 'horizon':
    enable              => $enable_horizon,
    port                => $horizon_port,
    public_port         => $horizon_ssl_port,
    options             => merge($common_http_options,
                                {
                                    'cookie'        => 'sessionid prefix',
                                    'option'        => ['http-server-close', 'httplog', 'forwardfor', "httpchk GET  /${::cloud::params::horizon_auth_url}  HTTP/1.0\\r\\nUser-Agent:\ HAproxy-${::hostname}"],
                                    'http-check'    => 'expect ! rstatus ^5',
                                    # Needs to match with SECURE_PROXY_SSL_HEADER in /etc/openstack-dashboard/local_settings.py
                                    'reqadd'        => 'X-Forwarded-Protocol:\ https if { ssl_fc }',
                                },
                                $horizon_options),

#    httpchk           => "httpchk GET  /${::cloud::params::horizon_auth_url}  \"HTTP/1.0\\r\\nUser-Agent: HAproxy-${::hostname}\"",
  }

  cloud::loadbalancer::bind_api { 'elasticsearch':
    enable              => $enable_elasticsearch,
    port                => $elasticsearch_port,
    options             => merge($common_http_options, $elasticsearch_options),
  }

  cloud::loadbalancer::bind_api { 'kibana':
    enable              => $enable_kibana,
    port                => $kibana_port,
    options             => merge($common_http_options, 
                                {
                                    'cookie'      => 'JSESSIONID prefix indirect nocache',
                                    'http-check'  => 'expect ! rstatus ^5',
                                    'balance'     => 'source',
                                },
                                $kibana_options),
  }

  cloud::loadbalancer::bind_api { 'logstash_syslog':
    enable              => $enable_logstash_syslog,
    port                => $logstash_syslog_port,
    options             => merge($common_tcp_options, $logstash_syslog_options),
  }

  cloud::loadbalancer::bind_api { 'redis':
    enable              => $enable_redis,
    port                => $redis_port,
    options             => merge($common_tcp_options, 
                                {
                                    'balance'   => 'first',
                                    'option'    => ['tcp-check',],
                                    'tcp-check' => ['send info\ replication\r\n','expect string role:master'],
                                },
                                $redis_options),
  }

  if (member(any2array($keepalived_public_ipvs), $galera_ip)) {
    warning('Exposing Galera to public network is a security issue.')
  }

  cloud::loadbalancer::bind_api { 'galera':
    enable              => $enable_galera,
    port                => $galera_port,
    options             => merge($common_tcp_options,
                                {
                                    'maxconn'        => $galera_connections,
                                    'mode'           => 'tcp',
                                    'balance'        => 'roundrobin',
                                    'option'         => ['tcpka', 'tcplog', 'httpchk'],   # httpchk mandatory expect 200 on port 9200
                                    'timeout client' => $galera_timeout,
                                    'timeout server' => $galera_timeout,
                                },
                                $galera_options),
  }

#  if $::cloud::manage_firewall {
#    cloud::firewall::rule{ '100 allow galera-slave binding access':
#      port   => '3307',
#      extras => $firewall_settings,
#    }
#  }

  cloud::loadbalancer::bind_api { 'galera_readonly':
    enable              => $enable_galera_readonly,
    port                => $galera_readonly_port,
    options             => merge($common_tcp_options,
                                {   
                                    'maxconn'        => $galera_connections,
                                    'mode'           => 'tcp',
                                    'balance'        => 'roundrobin',
                                    'option'         => ['tcpka', 'tcplog', 'httpchk'],   # httpchk mandatory expect 200 on port 9200
                                    'timeout client' => $galera_timeout,
                                    'timeout server' => $galera_timeout,
                                },
                                $galera_readonly_options),
  }

  # Allow HAProxy to bind to a non-local IP address
  $haproxy_sysctl_settings = {
    'net.ipv4.ip_nonlocal_bind' => { value => 1 }
  }
  create_resources(sysctl::value,$haproxy_sysctl_settings)

  if $::cloud::manage_firewall {

    cloud::firewall::rule{ '100 allow galera binding access':
      port   => '3306',
      extras => $firewall_settings,
    }

    cloud::firewall::rule{ '100 allow haproxy monitor access':
      port   => '10300',
      extras => $firewall_settings,
    }

    cloud::firewall::rule{ '100 allow keepalived access':
      port   => undef,
      proto  => 'vrrp',
      extras => $firewall_settings,
    }
  }

}
