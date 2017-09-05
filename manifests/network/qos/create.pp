#
# Author: Maik Srba <msrba@gwdg.de>
#
# Network qos create 
#
# Create neutron qos and assign bandwith
#
# === Parameters
#
# [*max_kbps*]
#   (optional) max bandwith in kbps
#   Defaults to 100000
#
# [*max_burst_kbps*]
#   (optional) The burst value given in kilobits, not in kilobits per second as the name of the parameter might suggest
#   Defaults to 80000
#
# [*os_project_name*]
#   (optional) The keystone project name.
#   Defaults to 'admin'.
#
# [*os_project_domain_id*]
#   (optional) The keystone project domain id.
#   Defaults to 'default'.
#
# [*os_username*]
#   (Optional) The keystone user name.
#   Defaults to 'admin'.
#
# [*os_user_domain_id*]
#   (optional) The keystone user domain id.
#   Defaults to 'default'.
#
# [*os_password*]
#   (Required) The keystone tenant:username password.
#
# [*os_auth_url*]
#   (Optional) The keystone auth url.
#   Defaults to 'http://127.0.0.1:5000/v2.0/'.
#
# [*os_region_name*]
#   (Optional) The keystone region name.
#   Default is unset.
#
define cloud::network::qos::create(
    $max_kbps             = 100000,
    $max_burst_kbps       = 80000,
    $os_project_name      = 'admin',
    $os_project_domain_id = 'default',
    $os_username          = 'admin',
    $os_user_domain_id    = 'default',
    $os_password,
    $os_auth_url          = 'http://127.0.0.1:5000/v2.0/',
    $os_region_name       = undef,
) {
  $policy_name = $name

  $env = [
    "OS_PROJECT_NAME=${os_project_name}",
    "OS_PROJECT_DOMAIN_ID=${os_project_domain_id}",
    "OS_USERNAME=${os_username}",
    "OS_USER_DOMAIN_ID=${os_user_domain_id}",
    "OS_PASSWORD=${os_password}",
    "OS_AUTH_URL=${os_auth_url}",
  ]

  if $os_region_name {
    $env = concat($env, ["OS_REGION_NAME=${os_region_name}"])
  }

  exec {"neutron qos-policy-create ${policy_name}":
    command     => "neutron qos-policy-create ${policy_name}",
    unless      => "neutron qos-policy-list -c name -f value | grep -qE '\\b${policy_name}\\b'",
    environment => $env,
    require     => Anchor['neutron::service::end'],
    path        => ['/usr/bin', '/bin'],
    try_sleep   => 5,
    tries       => 10,
    timeout     => 300,
  }

  exec {"neutron qos-bandwidth-limit-rule-create ${policy_name}":
    command     => "neutron qos-bandwidth-limit-rule-create --max-kbps ${max_kbps} --max-burst-kbps ${max_burst_kbps} ${policy_name}",
    unless      => "neutron qos-bandwidth-limit-rule-list ${policy_name} -c id -f value | grep -qE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'",
    environment => $env,
    require     => Anchor['neutron::service::end'],
    path        => ['/usr/bin', '/bin'],
    try_sleep   => 5,
    tries       => 10,
    timeout     => 300,
  }
}
