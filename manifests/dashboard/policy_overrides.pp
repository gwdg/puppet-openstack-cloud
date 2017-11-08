#
class cloud::dashboard::policy_overrides (

  $py_dir     = '/usr/lib/python2.7/dist-packages/',
  $py_mod     = 'dashboard_policies',
  $py_name    = 'override',
  $local_dir  = '/usr/share/openstack-dashboard/openstack_dashboard/local/local_settings.d/'

) {

  file { "${py_name}.py":
    ensure  => file,
    path    => "${py_dir}${py_mod}/${py_name}.py",
    source  => 'puppet:///modules/cloud/dashboard/override.py',
    owner   => root,
    group   => root,
    mode    => 'u+w',
    audit   => content,
  } 

  file { "__init__.py":
    ensure  => file,
    path    => "${py_dir}${py_mod}/__init__.py",
    owner   => root,
    group   => root,
    mode    => 'u+w',
  } 

  file { "${py_mod}":
    ensure  => directory,
    path    => "${py_dir}${py_mod}",
    owner   => root,
    group   => root,
    before  => File["${py_name}.py","__init__.py"]
  }

  file { '_set_custom_policy_checks.py':
    ensure  => file,
    path    => "${local_dir}/_set_custom_policy_checks.py",
    content => "HORIZON_CONFIG['customization_module'] = '${py_mod}.${py_name}'",
    owner   => root,
    group   => root,
    mode    => 'u+w',
  }
}

