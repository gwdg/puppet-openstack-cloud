# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless optional by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# MySQL Galera Node
#
# === Parameters
#
# [*api_eth*]
#   (optional) Hostname or IP to bind MySQL daemon.
#   Defaults to '127.0.0.1'
#
# [*galera_master_name*]
#   (optional) Hostname or IP of the Galera master node, databases and users
#   resources are created on this node and propagated on the cluster.
#   Defaults to 'mgmt001'
#
# [*galera_internal_ips*]
#   (optional) Array of internal ip of the galera nodes.
#   Defaults to ['127.0.0.1']
#
# [*galera_gcache*]
#   (optional) Size of the Galera gcache
#   wsrep_provider_options, for master/slave mode
#   Defaults to '1G'
#
# [*keystone_db_host*]
#   (optional) Host where user should be allowed all privileges for database.
#   Defaults to 127.0.0.1
#
# [*keystone_db_user*]
#   (optional) Name of keystone DB user.
#   Defaults to trove
#
# [*keystone_db_password*]
#   (optional) Password that will be used for the Keystone db user.
#   Defaults to 'keystonepassword'
#
# [*keystone_db_allowed_hosts*]
#   (optional) Hosts allowed to use the database
#   Defaults to ['127.0.0.1']
#
# [*cinder_db_host*]
#   (optional) Host where user should be allowed all privileges for database.
#   Defaults to 127.0.0.1
#
# [*cinder_db_user*]
#   (optional) Name of cinder DB user.
#   Defaults to trove
#
# [*cinder_db_password*]
#   (optional) Password that will be used for the cinder db user.
#   Defaults to 'cinderpassword'
#
# [*cinder_db_allowed_hosts*]
#   (optional) Hosts allowed to use the database
#   Defaults to ['127.0.0.1']
#
# [*glance_db_host*]
#   (optional) Host where user should be allowed all privileges for database.
#   Defaults to 127.0.0.1
#
# [*glance_db_user*]
#   (optional) Name of glance DB user.
#   Defaults to trove
#
# [*glance_db_password*]
#   (optional) Password that will be used for the glance db user.
#   Defaults to 'glancepassword'
#
# [*glance_db_allowed_hosts*]
#   (optional) Hosts allowed to use the database
#   Defaults to ['127.0.0.1']
#
# [*heat_db_host*]
#   (optional) Host where user should be allowed all privileges for database.
#   Defaults to 127.0.0.1
#
# [*heat_db_user*]
#   (optional) Name of heat DB user.
#   Defaults to trove
#
# [*heat_db_password*]
#   (optional) Password that will be used for the heat db user.
#   Defaults to 'heatpassword'
#
# [*heat_db_allowed_hosts*]
#   (optional) Hosts allowed to use the database
#   Defaults to ['127.0.0.1']
#
# [*nova_db_host*]
#   (optional) Host where user should be allowed all privileges for database.
#   Defaults to 127.0.0.1
#
# [*nova_db_user*]
#   (optional) Name of nova DB user.
#   Defaults to trove
#
# [*nova_db_password*]
#   (optional) Password that will be used for the nova db user.
#   Defaults to 'novapassword'
#
# [*nova_db_allowed_hosts*]
#   (optional) Hosts allowed to use the database
#   Defaults to ['127.0.0.1']
#
# [*neutron_db_host*]
#   (optional) Host where user should be allowed all privileges for database.
#   Defaults to 127.0.0.1
#
# [*neutron_db_user*]
#   (optional) Name of neutron DB user.
#   Defaults to trove
#
# [*neutron_db_password*]
#   (optional) Password that will be used for the neutron db user.
#   Defaults to 'neutronpassword'
#
# [*neutron_db_allowed_hosts*]
#   (optional) Hosts allowed to use the database
#   Defaults to ['127.0.0.1']
#
# [*trove_db_host*]
#   (optional) Host where user should be allowed all privileges for database.
#   Defaults to 127.0.0.1
#
# [*trove_db_user*]
#   (optional) Name of trove DB user.
#   Defaults to trove
#
# [*trove_db_password*]
#   (optional) Password that will be used for the trove db user.
#   Defaults to 'trovepassword'
#
# [*trove_db_allowed_hosts*]
#   (optional) Hosts allowed to use the database
#   Defaults to ['127.0.0.1']
#
# [*mysql_root_password*]
#   (optional) The MySQL root password.
#   Puppet will attempt to set the root password and update `/root/.my.cnf` with it.
#   Defaults to 'rootpassword'
#
# [*mysql_sys_maint_password*]
#   (optional) The MySQL debian-sys-maint password.
#   Debian only parameter.
#   Defaults to 'sys_maint'
#
# [*galera_clustercheck_dbuser*]
#   (optional) The MySQL username for Galera cluster check (using monitoring database)
#   Defaults to 'clustercheck'
#
# [*galera_clustercheck_dbpassword*]
#   (optional) The MySQL password for Galera cluster check
#   Defaults to 'clustercheckpassword'
#
# [*galera_clustercheck_ipaddress*]
#   (optional) The name or ip address of host running monitoring database (clustercheck)
#   Defaults to '127.0.0.1'
#
# [*open_files_limit*]
#   (optional) An integer that specifies the open_files_limit for MySQL
#   Defaults to 65535
#
# [*max_connections*]
#   (optional) An integer that specifies the max_connections for MySQL
#   Defaults to 4096
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::database::sql::mysql (

    $local_ip                        = '127.0.0.1',
    $bind_address                    = '127.0.0.1',

    $galera_master_name              = 'mgmt001',
    $galera_internal_ips             = ['127.0.0.1'],
    $galera_gcache                   = '1G',

    $keystone_db_host                = '127.0.0.1',
    $keystone_db_user                = 'keystone',
    $keystone_db_password            = 'keystonepassword',
    $keystone_db_allowed_hosts       = ['127.0.0.1'],

    $cinder_db_host                  = '127.0.0.1',
    $cinder_db_user                  = 'cinder',
    $cinder_db_password              = 'cinderpassword',
    $cinder_db_allowed_hosts         = ['127.0.0.1'],

    $glance_db_host                  = '127.0.0.1',
    $glance_db_user                  = 'glance',
    $glance_db_password              = 'glancepassword',
    $glance_db_allowed_hosts         = ['127.0.0.1'],

    $heat_db_host                    = '127.0.0.1',
    $heat_db_user                    = 'heat',
    $heat_db_password                = 'heatpassword',
    $heat_db_allowed_hosts           = ['127.0.0.1'],

    $nova_db_host                    = '127.0.0.1',
    $nova_db_user                    = 'nova',
    $nova_db_password                = 'novapassword',
    $nova_db_allowed_hosts           = ['127.0.0.1'],

    $nova_api_db_host                = '127.0.0.1',
    $nova_api_db_user                = 'nova_api',
    $nova_api_db_password            = 'nova_apipassword',
    $nova_api_db_allowed_hosts       = ['127.0.0.1'],

    $nova_placement_db_host          = '127.0.0.1',
    $nova_placement_db_user          = 'nova_placement',
    $nova_placement_db_password      = 'nova_placementpassword',
    $nova_placement_db_allowed_hosts = ['127.0.0.1'],

    $neutron_db_host                 = '127.0.0.1',
    $neutron_db_user                 = 'neutron',
    $neutron_db_password             = 'neutronpassword',
    $neutron_db_allowed_hosts        = ['127.0.0.1'],

    $trove_db_host                   = '127.0.0.1',
    $trove_db_user                   = 'trove',
    $trove_db_password               = 'trovepassword',
    $trove_db_allowed_hosts          = ['127.0.0.1'],

    $magnum_db_host                  = '127.0.0.1',
    $magnum_db_user                  = 'magnum',
    $magnum_db_password              = 'magnumpassword',
    $magnum_db_allowed_hosts         = ['127.0.0.1'],

    $aodh_db_host                    = '127.0.0.1',
    $aodh_db_user                    = 'aodh',
    $aodh_db_password                = 'aodhpassword',
    $aodh_db_allowed_hosts           = ['127.0.0.1'],

    $gnocchi_db_host                 = '127.0.0.1',
    $gnocchi_db_user                 = 'gnocchi',
    $gnocchi_db_password             = 'gnocchipassword',
    $gnocchi_db_allowed_hosts        = ['127.0.0.1'],

    $ceilometer_db_host              = '127.0.0.1',
    $ceilometer_db_user              = 'ceilometer',
    $ceilometer_db_password          = 'ceilometerpassword',
    $ceilometer_db_allowed_hosts     = ['127.0.0.1'],

    $mysql_root_password             = 'rootpassword',

    $mysql_sys_maint_password        = 'sys_maint',
    $galera_clustercheck_dbuser      = 'clustercheck',
    $galera_clustercheck_dbpassword  = 'clustercheckpassword',
    $galera_clustercheck_ipaddress   = '127.0.0.1',
    $open_files_limit                = 65535,
    $max_connections                 = 4096,

    $mysql_systemd_override_settings = {},
    $firewall_settings               = {},
) {

  # Specific to the Galera master node
  if $::fqdn == $galera_master_name {

#    Mysql_user <| |> -> File['/root/.my.cnf'] 

    # OpenStack DB
    class { '::keystone::db::mysql':
      dbname        => 'keystone',
      user          => $keystone_db_user,
      password      => $keystone_db_password,
      host          => $keystone_db_host,
      allowed_hosts => $keystone_db_allowed_hosts,
    }

    class { '::glance::db::mysql':
      dbname        => 'glance',
      user          => $glance_db_user,
      password      => $glance_db_password,
      host          => $glance_db_host,
      allowed_hosts => $glance_db_allowed_hosts,
    }

    class { '::nova::db::mysql':
      dbname        => 'nova',
      user          => $nova_db_user,
      password      => $nova_db_password,
      host          => $nova_db_host,
      allowed_hosts => $nova_db_allowed_hosts,
    }

    class { '::nova::db::mysql_api':
      dbname        => 'nova_api',
      user          => $nova_api_db_user,
      password      => $nova_api_db_password,
      host          => $nova_api_db_host,
      allowed_hosts => $nova_api_db_allowed_hosts,
    }

    class { '::nova::db::mysql_placement':
      dbname        => 'nova_placement',
      user          => $nova_placement_db_user,
      password      => $nova_placement_db_password,
      host          => $nova_placement_db_host,
      allowed_hosts => $nova_placement_db_allowed_hosts,
    }

    class { '::cinder::db::mysql':
      dbname        => 'cinder',
      user          => $cinder_db_user,
      password      => $cinder_db_password,
      host          => $cinder_db_host,
      allowed_hosts => $cinder_db_allowed_hosts,
    }

    class { '::neutron::db::mysql':
      dbname        => 'neutron',
      user          => $neutron_db_user,
      password      => $neutron_db_password,
      host          => $neutron_db_host,
      allowed_hosts => $neutron_db_allowed_hosts,
    }

    class { '::heat::db::mysql':
      dbname        => 'heat',
      user          => $heat_db_user,
      password      => $heat_db_password,
      host          => $heat_db_host,
      allowed_hosts => $heat_db_allowed_hosts,
    }

    class { '::trove::db::mysql':
      dbname        => 'trove',
      user          => $trove_db_user,
      password      => $trove_db_password,
      host          => $trove_db_host,
      allowed_hosts => $trove_db_allowed_hosts,
    }

    class { '::magnum::db::mysql':
      dbname        => 'magnum',
      user          => $magnum_db_user,
      password      => $magnum_db_password,
      host          => $magnum_db_host,
      allowed_hosts => $magnum_db_allowed_hosts,
    }

    class { '::aodh::db::mysql':
      dbname        => 'aodh',
      user          => $aodh_db_user,
      password      => $aodh_db_password,
      host          => $aodh_db_host,
      allowed_hosts => $aodh_db_allowed_hosts,
    }

    class { '::gnocchi::db::mysql':
      dbname        => 'gnocchi',
      user          => $gnocchi_db_user,
      password      => $gnocchi_db_password,
      host          => $gnocchi_db_host,
      allowed_hosts => $gnocchi_db_allowed_hosts,
    }

    class { '::ceilometer::db::mysql':
      dbname        => 'ceilometer',
      user          => $ceilometer_db_user,
      password      => $ceilometer_db_password,
      host          => $ceilometer_db_host,
      allowed_hosts => $ceilometer_db_allowed_hosts,
    }

    # Monitoring DB
#    mysql_database { 'monitoring':
#      ensure  => 'present',
#      charset => 'utf8',
#      collate => 'utf8_general_ci',
#      require => File['/root/.my.cnf']
#    }

#    Mysql_user<<| |>>

  }

  # Galera setup
  class { '::galera':

    galera_servers                  => $galera_internal_ips,
    galera_master                   => $galera_master_name,

    status_password                 => $galera_clustercheck_dbpassword,

    vendor_type                     => 'codership',

    # These options are only used for the firewall - 
    # to change the my.cnf settings, use the override options
    # described below

#    mysql_port                     => 3306, 
#    wsrep_state_transfer_port      => 4444,
#    wsrep_inc_state_transfer_port  => 4568,

    # This is used for the firewall + for status checks when deciding whether to bootstrap
    wsrep_group_comm_port           => 4567,

    local_ip                        => $local_ip,
    bind_address                    => $bind_address,

    root_password                   => $mysql_root_password,
    create_root_my_cnf              => true,

    configure_repo                  => false,
    configure_firewall              => false,

#    override_options   => {
#      'mysqld' => {
#        'bind-address' => $bind_address
#      }
#    },
  }

  class { '::mysql::client':
    package_name => $mysql_client_package_name,
  }

  # Firewall can also be managed from the galera modul
#  if $::cloud::manage_firewall {
#    cloud::firewall::rule{ '100 allow galera access':
#      port   => ['3306', '4567', '4568', '4444'],
#      extras => $firewall_settings,
#    }
#    cloud::firewall::rule{ '100 allow mysqlchk access':
#      port   => '8200',
#      extras => $firewall_settings,
#    }
#    cloud::firewall::rule{ '100 allow mysql rsync access':
#      port   => '873',
#      extras => $firewall_settings,
#    }
#  }

  @@haproxy::balancermember{$::fqdn:
    listening_service => 'galera',
    server_names      => $::hostname,
    ipaddresses       => $local_ip,
    ports             => '3306',
    options           =>
      inline_template('check inter 2000 rise 2 fall 5 port 9200 <% if @fqdn != @galera_master_name -%>backup<% end %> on-marked-down shutdown-sessions')
  }

  @@haproxy::balancermember{"${::fqdn}-readonly":
    listening_service => 'galera_readonly',
    server_names      => $::hostname,
    ipaddresses       => $local_ip,
    ports             => '3306',
    options           =>
      inline_template('check inter 2000 rise 2 fall 5 port 9200 <% if @fqdn == @galera_master_name -%>backup<% end %> on-marked-down shutdown-sessions')
  }
}
