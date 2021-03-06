# == Define: cloud::volume::qos::create
#
# Creates cinder qos and assigns type.
#
# === Parameters
#
# [*os_password*]
#   (Required) The keystone tenant:username password.
#
# [*consumer*]
#   (Required) Consumer of the qos possible value [front-end|back-end] Defaults to 'front-end'.
#
# [*properties*]
#   (Optional) Accepts a hash with key value pairs for qos definition
#   Defaults to 'undef'.
#
# [*os_tenant_name*]
#   (Optional) The keystone tenant name.
#   Defaults to 'admin'.
#
# [*os_username*]
#   (Optional) The keystone user name.
#   Defaults to 'admin.
#
# [*os_auth_url*]
#   (Optional) The keystone auth url.
#   Defaults to 'http://127.0.0.1:5000/v2.0/'.
#
# [*os_region_name*]
#   (Optional) The keystone region name.
#   Default is unset.
#
# Author: Maik Srba <msrba@gwdg.de>
#
define cloud::volume::qos::create (
  $os_password,
  $consumer             = 'front-end',
  $properties           = undef,
  $os_tenant_name       = 'admin',
  $os_username          = 'admin',
  $os_auth_url          = 'http://127.0.0.1:5000/v2.0/',
  $os_region_name       = undef,
  $os_project_domain_id = 'default',
  $os_user_domain_id    = 'default',

  ) {

  $qos_name = $name

  $qos_env = [
    "OS_IDENTITY_API_VERSION=3",
    "OS_PROJECT_NAME=${os_tenant_name}",
    "OS_USERNAME=${os_username}",
    "OS_PASSWORD=${os_password}",
    "OS_AUTH_URL=${os_auth_url}",
    "OS_VOLUME_API_VERSION=1",
    "OS_PROJECT_DOMAIN_ID=${os_project_domain_id}",
    "OS_USER_DOMAIN_ID=${os_user_domain_id}",
  ]

  if $os_region_name {
    $region_env = ["OS_REGION_NAME=${os_region_name}"]
  }
  else {
    $region_env = []
  }

  exec {"openstack volume qos create ${qos_name}":
    command     => "openstack volume qos create ${qos_name} --consumer=front-end",
    unless      => "openstack volume qos list -c Name -f value | grep -qE '\\b${qos_name}\\b'",
    environment => concat($qos_env, $region_env),
    require     => [Anchor['cinder::service::end'], Package['python-cinderclient']],
    path        => ['/usr/bin', '/bin'],
    tries       => '2',
    try_sleep   => '5',
  }
  
 # notify{"properties for qos: ${properties}": }
 
  if $properties {
    Exec["openstack volume qos create ${qos_name}"] ->
    Cloud::Volume::Qos::Set<| qos_name == $qos_name |>    

    create_resources(
      'cloud::volume::qos::set', 
      $properties, 
      {
        qos_name       => $qos_name,
        os_tenant_name => $os_tenant_name,
        os_username    => $os_username,
        os_password    => $os_password,
        os_auth_url    => $os_auth_url,
        os_region_name => $os_region_name,
      }
    )
  }
}
