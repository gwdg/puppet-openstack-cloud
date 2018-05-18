# == Class: cloud::auth_file
#
# Creates an auth file that can be used to export
# environment variables that can be used to authenticate
# against a keystone server.
#
# === Parameters
#
# [*password*]
#   (required) Password.
# [*keystone_host*]
#   (optional) Keystone address. Defaults to '127.0.0.1'.
# [*admin_token*]
#   (optional) Admin token.
#   NOTE: This setting will trigger a warning from keystone.
#   Authentication credentials will be ignored by keystone client
#   in favor of token authentication. Defaults to undef.
# [*User*]
#   (optional) Defaults to 'admin'.
# [*Project*]
#   (optional) Defaults to 'admin'.
# [*interface_type*]
#   (optional) Defaults to 'internal'.

class cloud::auth_file(
  $auth_url         = 'http://127.0.0.1:5000/v3/',
  $admin_token      = undef,
  $user             = 'admin',
  $password         = undef,
  $project          = 'admin',
  $interface_type   = 'internal',
  $domain_id        = 'default'
) {

  include ::openstacklib::openstackclient

  class { '::openstack_extras::auth_file':
    path                   => "/root/auth_${user}.sh",
    password               => $password,
    project_name           => $project,
    project_domain         => $domain_id,
    username               => $user,
    user_domain            => $domain_id,
    auth_url               => $auth_url,
    cinder_endpoint_type   => 'internalURL',
    glance_endpoint_type   => 'internalURL',
    keystone_endpoint_type => 'internalURL',
    nova_endpoint_type     => 'internalURL',
    neutron_endpoint_type  => 'internalURL',
  }
}
