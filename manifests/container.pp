#
# Copyright (C) 2016 GWDG <support@gwdg.com>
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
# == Class: cloud::container
#
# Container common node
#
# === Parameters:
# [*verbose*]
#   (optional) Set log output to verbose output
#   Defaults to true
#
# [*debug*]
#   (optional) Set log output to debug output
#   Defaults to true
#
# [*use_syslog*]
#   (optional) Use syslog for logging
#   Defaults to true
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines
#   Defaults to 'LOG_LOCAL0'
#
class cloud::container(
  $verbose                    = true,
  $debug                      = true,
  $use_syslog                 = true,
  $log_facility               = 'LOG_LOCAL0'
){

	include 'mysql::client'

	# Configure logging for magnum
	class { '::magnum::logging':
	    use_syslog                      => $use_syslog,
	    log_facility                    => $log_facility,
	    verbose                         => $verbose,
	    debug                           => $debug,

	    logging_context_format_string   => '%(process)d: %(levelname)s %(name)s [%(request_id)s %(user_identity)s] %(instance)s%(message)s',
	    logging_default_format_string   => '%(process)d: %(levelname)s %(name)s [-] %(instance)s%(message)s',
	    logging_debug_format_suffix     => '%(funcName)s %(pathname)s:%(lineno)d',
	    logging_exception_prefix        => '%(process)d: TRACE %(name)s %(instance)s',

	    require                         => Exec ['/tmp/setup_magnum.sh']
	}

	file { '/tmp/setup_magnum.sh':
    	ensure => file,
    	source => 'puppet:///modules/cloud/magnum/setup_magnum.sh',
    	owner  => root,
    	group  => root,
    	mode   => 'u+x',
    	audit  => content,
  	} 

  	exec { '/tmp/setup_magnum.sh':
    	subscribe => File['/tmp/setup_magnum.sh'],
  	}

	#Install Pip
	#class { '::python': }

	#Install Magnum Api / Magnum Conductor (require Python / Pip) until we have packages
	#class { '::python::pip':
    #	pkgname       => 'magnum',
	#	ensure 	      => 'tags/2.0.0', #branch
	#	url        	  => 'git+https://github.com/openstack/magnum.git',
	#	install_args  => '-e',
	#	require       => Class['::python'],
	#}

	#Install Magnum Client (require Python / Pip) until we have packages
	#class { '::python::pip':
	#	pkgname       => 'magnum-client',
	#	ensure        => 'tags/2.0.0',#branch
	#	url           => 'git+https://github.com/openstack/python-magnumclient.git'
	#	install_args  => '-e',
	#	require       => Class['::python'],
	#}


}