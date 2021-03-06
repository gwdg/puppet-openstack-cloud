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
# == Class: cloud::messaging
#
# Install Messsaging Server (RabbitMQ)
#
# === Parameters:
#
# [*rabbit_names*]
#   (optional) List of RabbitMQ servers. Should be an array.
#   Defaults to $::hostname
#
# [*rabbit_password*]
#   (optional) Password to connect to OpenStack queues.
#   Defaults to 'rabbitpassword'
#
# [*cluster_node_type*]
#   (optional) Store the queues on the disc or in the RAM.
#   Could be set to 'disk' or 'ram'.
#   Defaults to 'disc'
#
# [*cluster_count*]
#   (optional) Queue is mirrored to count nodes in the cluster.
#   If there are less than count nodes in the cluster, the queue
#   is mirrored to all nodes. If there are more than count nodes
#   in the cluster, and a node containing a mirror goes down,
#   then a new mirror will be created on another node.
#   If a value is set, RabbitMQ policy will be 'exactly'.
#   Otherwise, undef will set the policy to 'all' by default.
#   To enable this feature, you need 'haproxy_binding' to true.
#   Defaults to undef
#
# [*haproxy_binding*]
#   (optional) Enable or not HAproxy binding for load-balancing.
#   Defaults to false
#
# [*rabbitmq_ip*]
#   (optional) IP address of RabbitMQ interface.
#   Required when using HAproxy binding.
#   Defaults to $::ipaddress
#
# [*rabbitmq_port*]
#   (optional) Port of RabbitMQ service.
#   Defaults to '5672'
#
# [*erlang_cookie*]
#   (required) Erlang cookie to use.
#   When running a cluster, this value should be the same for all
#   the nodes.
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
# [*rabbitmq_master_name*]
#   (required) Name of the rabbitmq master node.
#   Defaults to $::hostname
#
# [*rabbitmq_management_port*]
#   (required) Port for the rabbitmq management api / webui.
#   Defaults to 15672
#
class cloud::messaging(
  $erlang_cookie,
  $cluster_node_type        = 'disc',
  $cluster_count            = undef,
  $rabbit_names             = $::hostname,
  $rabbit_password          = 'rabbitpassword',
  $haproxy_binding          = false,
  $rabbitmq_ip              = $::ipaddress,
  $rabbitmq_port            = '5672',
  $firewall_settings        = {},

  $rabbitmq_master_name     = 'messaging1',
  $rabbitmq_cluster_name    = 'rabbit@messaging1.dev.cloud.gwdg.de',
  $rabbitmq_management_port = '15672',
){

  # we ensure having an array
  $array_rabbit_names = any2array($rabbit_names)

  Class['::rabbitmq'] -> Rabbitmq_vhost <<| |>>
  Class['::rabbitmq'] -> Rabbitmq_user <<| |>>
  Class['::rabbitmq'] -> Rabbitmq_user_permissions <<| |>>

  # Differentiate between master and slave nodes to allow automatic cluster join
  if $::hostname != $rabbitmq_master_name {
    $sleep_after_state_change   = "5"
    exec { 'join-rabbitmq-cluster':
      command   => "/usr/sbin/rabbitmqctl stop_app; /bin/sleep ${sleep_after_state_change}; /usr/sbin/rabbitmqctl join_cluster rabbit@${rabbitmq_master_name}; /usr/sbin/rabbitmqctl start_app; /bin/sleep ${sleep_after_state_change}",
      unless    => "/usr/sbin/rabbitmqctl -q cluster_status | grep '{cluster_name,<<\"${rabbitmq_cluster_name}\">>}'",
      require   => Class['rabbitmq'],
    }
  }

  class { '::rabbitmq':
    delete_guest_user        => true,
    config_cluster           => true,
    cluster_nodes            => $array_rabbit_names,
    wipe_db_on_cookie_change => true,
    cluster_node_type        => $cluster_node_type,
    node_ip_address          => $rabbitmq_ip,
    port                     => $rabbitmq_port,
    erlang_cookie            => $erlang_cookie,
  }

  rabbitmq_vhost { ['/', '/sensu']:
    provider => 'rabbitmqctl',
    require  => Class['rabbitmq'],
  }
  rabbitmq_user { ['nova','glance','neutron','cinder','ceilometer', 'aodh', 'heat','trove','magnum','sensu']:
    admin    => true,
    password => $rabbit_password,
    provider => 'rabbitmqctl',
    require  => Class['rabbitmq']
  }
  rabbitmq_user_permissions {[
    'nova@/',
    'glance@/',
    'neutron@/',
    'cinder@/',
    'ceilometer@/',
    'aodh@/',
    'heat@/',
    'trove@/',
    'magnum@/',
    'sensu@/sensu',
  ]:
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
  }
  rabbitmq_user { 'telegraf':
    password => $rabbit_password,
    provider => 'rabbitmqctl',
    tags     => ['monitoring'],
    require  => Class['rabbitmq']
  }
  rabbitmq_user_permissions {'telegraf@/':
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow rabbitmq access':
      port   => $rabbitmq_port,
      extras => $firewall_settings,
    }
    cloud::firewall::rule{ '100 allow rabbitmq management access':
      port   => $rabbitmq_management_port,
      extras => $firewall_settings,
    }
  }

  if $haproxy_binding {

    if $cluster_count {
      $policy_name = "ha-exactly-${cluster_count}@/"
      $definition = {
        'ha-mode'   => 'exactly',
        'ha-params' => $cluster_count,
      }
    } else {
      $policy_name = 'ha-all@/'
      $definition = {
        'ha-mode' => 'all',
      }
    }
    rabbitmq_policy { $policy_name:
      pattern    => '^(?!amq\.).*',
      definition => $definition,
    }

    @@haproxy::balancermember{"${::fqdn}-rabbitmq":
      listening_service => 'rabbitmq',
      server_names      => $::hostname,
      ipaddresses       => $rabbitmq_ip,
      ports             => $rabbitmq_port,
      options           => 
#        'check inter 5s rise 2 fall 3',
        inline_template('check inter 5s rise 2 fall 3 <% if @fqdn != @rabbitmq_master_name -%>backup<% end %>')
    }

    @@haproxy::balancermember{"${::fqdn}-rabbitmq-management":
      listening_service => 'rabbitmq_management',
      server_names      => $::hostname,
      ipaddresses       => $rabbitmq_ip,
      ports             => $rabbitmq_management_port,
      options           =>
#        'check inter 5s rise 2 fall 3',
        inline_template('check inter 5s rise 2 fall 3 <% if @fqdn != @rabbitmq_master_name -%>backup<% end %>')
    }
  }

}
