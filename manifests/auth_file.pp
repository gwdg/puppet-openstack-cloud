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
  $keystone_host    = '127.0.0.1',
  $admin_token      = undef,
  $user             = 'admin',
  $password         = undef,
  $project          = 'admin',
  $interface_type   = 'internal',
  $domain_id        = 'default'
) {

  include ::openstacklib::openstackclient

  file { "/root/auth_${user}.sh":
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => template("${module_name}/openrc.erb")
  }
}
