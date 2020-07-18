# ==Define: cloud::volume::qos::associate
#
# Associate qos with the volume type.
#
# === Parameters
#
# [*os_password*]
#   (required) The keystone tenant:username password.
#
# [*qos_name*]
#   (required) Accepts single name of qos to associate.
#
# [*volume_type*]
#   (required) the associated volume_type for the qos.
#
# [*os_tenant_name*]
#   (optional) The keystone tenant name. Defaults to 'admin'.
#
# [*os_username*]
#   (optional) The keystone user name. Defaults to 'admin.
#
# [*os_auth_url*]
#   (optional) The keystone auth url. Defaults to 'http://127.0.0.1:5000/v2.0/'.
#
# [*os_region_name*]
#   (optional) The keystone region name. Default is unset.
#
# Author: Maik Srba <msrba@gwdg.de>


define cloud::volume::qos::associate (
  $qos_name,
  $volume_type,
  $os_password,
  $os_tenant_name       = 'admin',
  $os_username          = 'admin',
  $os_auth_url          = 'http://127.0.0.1:5000/v2.0/',
  $os_region_name       = undef,
  $os_project_domain_id = 'default',
  $os_user_domain_id    = 'default',
  ) {

  $qos_env = [
    "OS_IDENTITY_API_VERSION=3",
    "OS_PROJECT_NAME=${os_tenant_name}",
    "OS_USERNAME=${os_username}",
    "OS_PASSWORD=${os_password}",
    "OS_AUTH_URL=${os_auth_url}",
    "OS_VOLUME_API_VERSION=3",
    "OS_PROJECT_DOMAIN_ID=${os_project_domain_id}",
    "OS_USER_DOMAIN_ID=${os_user_domain_id}",
  ]

  if $os_region_name {
    $region_env = ["OS_REGION_NAME=${os_region_name}"]
  }
  else {
    $region_env = []
  }

  exec {"openstack volume qos associate ${qos_name} with ${volume_type}":
    path        => ['/usr/bin', '/bin'],
    command     => "openstack volume qos associate ${qos_name} ${volume_type}",
    unless      => "openstack volume qos show ${qos_name} -f value -c associations | grep -Eq '\\b${volume_type}\\b'",
    environment => concat($qos_env, $region_env),
    require     => [Anchor['cinder::service::end'], Package['python-cinderclient']],
  }
}
