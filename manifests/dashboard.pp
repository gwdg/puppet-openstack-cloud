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
# == Class: cloud::dashboard
#
# Installs the OpenStack Dashboard (Horizon)
#
# === Parameters:
#
# [*ks_keystone_internal_host*]
#   (optional) Internal address for endpoint.
#   Defaults to '127.0.0.1'
#
# [*secret_key*]
#   (optional) Secret key. This is used by Django to provide cryptographic
#   signing, and should be set to a unique, unpredictable value.
#   Defaults to 'secrete'
#
# [*horizon_port*]
#   (optional) Port used to connect to OpenStack Dashboard
#   Defaults to '80'
#
# [*horizon_ssl_port*]
#   (optional) Port used to connect to OpenStack Dashboard using SSL
#   Defaults to '443'
#
# [*api_eth*]
#   (optional) Which interface we bind the Horizon server.
#   Defaults to '127.0.0.1'
#
# [*servername*]
#   (optional) DNS name used to connect to OpenStack Dashboard.
#   Default value fqdn.
#
# [*listen_ssl*]
#   (optional) Enable SSL on OpenStack Dashboard vhost
#   It requires SSL files (keys and certificates)
#   Defaults false
#
# [*keystone_proto*]
#   (optional) Protocol (http or https) of keystone endpoint.
#   Defaults to 'http'
#
# [*keystone_host*]
#   (optional) IP / Host of keystone endpoint.
#   Defaults '127.0.0.1'
#
# [*keystone_port*]
#   (optional) TCP port of keystone endpoint.
#   Defaults to '5000'
#
# [*debug*]
#   (optional) Enable debug or not.
#   Defaults to true
#
# [*horizon_cert*]
#   (required with listen_ssl) Certificate to use for SSL support.
#
# [*horizon_key*]
#   (required with listen_ssl) Private key to use for SSL support.
#
# [*horizon_ca*]
#   (required with listen_ssl) CA certificate to use for SSL support.
#
# [*ssl_forward*]
#   (optional) Forward HTTPS proto in the headers
#   Useful when activating SSL binding on HAproxy and not in Horizon.
#   Defaults to false
#
#  [*os_endpoint_type*]
#    (optional) endpoint type to use for the endpoints in the Keystone
#    service catalog. Defaults to 'undef'.
#
#  [*allowed_hosts*]
#    (optional) List of hosts which will be set as value of ALLOWED_HOSTS
#    parameter in settings_local.py. This is used by Django for
#    security reasons. Can be set to * in environments where security is
#    deemed unimportant.
#    Defaults to ::fqdn.
#
#  [*vhost_extra_params*]
#    (optionnal) extra parameter to pass to the apache::vhost class
#    Defaults to {}
#
# [*neutron_extra_options*]
#   (optional) Enable optional services provided by neutron
#   Useful when using cisco n1kv plugin, vpnaas or fwaas.
#   Default to {}
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::dashboard(
  $ks_keystone_internal_host = '127.0.0.1',
  $secret_key                = 'secrete',
  $horizon_port              = 80,
  $horizon_ssl_port          = 443,
  $servername                = $::fqdn,
  $api_eth                   = '127.0.0.1',
  $keystone_host             = '127.0.0.1',
  $keystone_proto            = 'http',
  $keystone_port             = 5000,
  $debug                     = true,
  $listen_ssl                = false,
  $horizon_cert              = undef,
  $horizon_key               = undef,
  $horizon_ca                = undef,
  $os_endpoint_type          = undef,
  $allowed_hosts             = $::fqdn,
  $vhost_extra_params        = {},
  $neutron_extra_options     = {},
  $firewall_settings         = {},

  # New parameters
  $lb_eth                    = '127.0.0.1',
  $memcache_servers          = false,
  $compress_offline          = true,
  $root_path                 = "/usr/share/openstack-dashboard",
  $ssh_redirect_url          = undef,
) {

  # Active mod status for monitoring of Apache
  include ::apache::mod::status

  # We build the param needed for horizon class
  $keystone_url = "${keystone_proto}://${keystone_host}:${keystone_port}"

  # Use memcache servers for caching if set, else in memory caching
  if $memcache_servers {
    $cache_server_ip    = $memcache_servers
    $cache_backend      = 'django.core.cache.backends.memcached.MemcachedCache'
  } else {
    $cache_server_ip    = false
    $cache_backend      = 'django.core.cache.backends.locmem.LocMemCache'
  }
#  include ::cloud::util::apache_common
  if ! $::cloud::production {
       #redirect address in vagrant (with port)
       $part1 = $ssh_redirect_url[0,-9]
       $part2 = $ssh_redirect_url[-8,8]
       $ssh_redirect_url_real = "$part1:58080$part2"
  }
  else{
       #redirect address in production (withouth port)
       $ssh_redirect_url_real = $ssh_redirect_url
  }
  class { '::horizon':
    secret_key              => $secret_key,
    servername              => $servername,
    allowed_hosts           => $allowed_hosts,
    listen_ssl              => $listen_ssl,
    horizon_cert            => $horizon_cert,
    horizon_key             => $horizon_key,
    horizon_ca              => $horizon_ca,
    keystone_url            => hiera('cloud::global::identity::auth_uri'),
    cache_server_ip         => $cache_server_ip,
    cache_backend           => $cache_backend,
    neutron_options         => $neutron_extra_options,
    vhost_extra_params      => $vhost_extra_params,
    openstack_endpoint_type => $os_endpoint_type,
    root_path               => $root_path,
    # need to disable offline compression due to
    # https://bugs.launchpad.net/ubuntu/+source/horizon/+bug/1424042
    compress_offline        => $compress_offline,
    bind_address            => $api_eth,
    #django_debug            => $debug,
    allowed_hosts           => $allowed_hosts,
    ssl_forward             => $ssl_forward,
    ssh_redirect_url        => $ssh_redirect_url_real,
  }

#  class { '::cloud::dashboard::gwdg_theme':
#    require => Package['horizon'],
#    compress_offline => true,
#  }

#  class { '::cloud::dashboard::overrides':
#    require => Package['horizon'],
#  }

#  if ($::osfamily == 'Debian') {
#    # TODO(Goneri): HACK to ensure Horizon can cache its files
#    $horizon_var_dir = [ '/var/lib/openstack-dashboard/static', '/var/lib/openstack-dashboard/static/js', '/var/lib/openstack-dashboard/static/css']
#    file {$horizon_var_dir:
#      ensure    => directory,
#      owner     => 'horizon',
#      group     => 'horizon',
#      require   => Class['horizon'],
#    }
#  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow horizon access':
      port   => $horizon_port,
      extras => $firewall_settings,
    }
  }

  @@haproxy::balancermember{"${::fqdn}-horizon":
    listening_service => 'horizon',
    server_names      => $::hostname,
    ipaddresses       => $lb_eth,
    ports             => $horizon_port,
    options           => "check inter 2000 rise 2 fall 5 cookie ${::hostname}"
  }

  if $listen_ssl {

    if $::cloud::manage_firewall {
      cloud::firewall::rule{ '100 allow horizon ssl access':
        port   => $horizon_ssl_port,
        extras => $firewall_settings,
      }
    }

    @@haproxy::balancermember{"${::fqdn}-horizon-ssl":
      listening_service => 'horizon_ssl',
      server_names      => $::hostname,
      ipaddresses       => $lb_eth,
      ports             => $horizon_ssl_port,
      options           => "check inter 2000 rise 2 fall 5 cookie ${::hostname}"
    }
  }
}
