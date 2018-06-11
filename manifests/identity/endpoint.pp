# == Define: cloud::identity::endpoint
#
# Creates an enpoint for the service
#
# === Parameters
#
# [*password*]
#   (Required) The keystone password.
#
# Author: Maik Srba <msrba@gwdg.de>
#
define cloud::identity::endpoint (
  $auth_class = undef,
){

  if !$auth_class {
    $auth_class = "::${name}::keystone::auth"
  }

  class { $auth_class: }

}
