# == Class: cloud::container::domain
#
# Configures Magnum domain in Keystone.
#
# === Parameters
#
# [*magnum_domain_name*]
#   Magnum domain name. Defaults to 'magnum'.
#
# [*magnum_domain_admin*]
#   Keystone domain admin user which will be created. Defaults to 'magnum_admin'.
#
# [*magnum_domain_admin_email*]
#   Keystone domain admin user email address. Defaults to 'magnum_admin@localhost'.
#
# [*magnum_domain_password*]
#   Keystone domain admin user password. Defaults to 'changeme'.
#
class cloud::container::domain (
  $magnum_domain_name           = 'magnum',
  $magnum_domain_admin          = 'magnum_admin',
  $magnum_domain_admin_email    = 'magnum_admin@localhost',
  $magnum_domain_password       = 'magnumdomainpassword',
) {

  ensure_resource('keystone_domain', $magnum_domain_name, {
    'ensure'  => 'present',
    'enabled' => true,
  })

  ensure_resource('keystone_user', "${magnum_domain_admin}::${magnum_domain_name}", {
      'ensure'   => 'present',
      'enabled'  => true,
      'email'    => $magnum_domain_admin_email,
      'password' => $magnum_domain_password,
  })
    
  ensure_resource('keystone_user_role', "${magnum_domain_admin}::${magnum_domain_name}@::${magnum_domain_name}", {
    'roles' => ['admin'],
  })
}
