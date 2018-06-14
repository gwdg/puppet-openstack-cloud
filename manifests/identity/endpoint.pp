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
  $public_url,
  $internal_url,
  $admin_url,
  $region,
  $password,
){

  if !$auth_class {
    $real_auth_class = "::${name}::keystone::auth"
  } else {
    $real_auth_class = $auth_class
  }

  class { $real_auth_class: 
    public_url          => $public_url,
    internal_url        => $internal_url,
    admin_url           => $admin_url,
    region              => $region,
    password            => $password
  }

}
