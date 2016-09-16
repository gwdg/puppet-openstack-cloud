# == Class: cloud::orchestration::domain
#
# Configures Heat domain in Keystone.
#
# === Parameters
#
# [*domain_name*]
#   Heat domain name. Defaults to 'heat'.
#
# [*domain_admin*]
#   Keystone domain admin user which will be created. Defaults to 'heat_admin'.
#
# [*domain_admin_email*]
#   Keystone domain admin user email address. Defaults to 'heat_admin@localhost'.
#
# [*domain_password*]
#   Keystone domain admin user password. Defaults to 'changeme'.
#
class cloud::orchestration::domain (
  $domain_name        = 'heat',
  $domain_admin       = 'heat_admin',
  $domain_admin_email = 'heat_admin@localhost',
  $domain_password    = 'changeme',
) {

  ensure_resource('keystone_domain', $domain_name, {
    'ensure'  => 'present',
    'enabled' => true,
  })
  
  ensure_resource('keystone_user', "${domain_admin}::${domain_name}", {
    'ensure'   => 'present',
    'enabled'  => true,
    'email'    => $domain_admin_email,
    'password' => $domain_password,
  })
  
  ensure_resource('keystone_user_role', "${domain_admin}::${domain_name}@::${domain_name}", {
    'roles' => ['admin'],
  })
}