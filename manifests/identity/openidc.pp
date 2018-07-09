#
# == Class: cloud::identity::openidc
#
# Configure openidconnect for keystone
#
class cloud::identity::openidc (
){

  class { '::keystone::federation::openidc': }

  #create domain for fedcloud 
  #create projects for fedcloud
}
