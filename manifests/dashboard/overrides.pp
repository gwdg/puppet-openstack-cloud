class cloud::dashboard::overrides (

  $py_dir   = '/usr/lib/python2.7/dist-packages',
  $mod_name = 'dashboard_overrides',
  $dash_dir = '/usr/share/openstack-dashboard/openstack_dashboard',
  $settings = "${dash_dir}/local/local_settings.d",

) {

  file { "__init__.py":
    ensure  => file,
    path    => "${py_dir}/${mod_name}/__init__.py",
    owner   => root,
    group   => root,
    mode    => 'u+w',
  } 

  file { "overrides.py":
    ensure  => file,
    path    => "${py_dir}/${mod_name}/overrides.py",
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/cloud/dashboard/overrides.py',
    mode    => 'u+w',
  } 

  file { "$mod_name":
    ensure  => directory,
    path    => "${py_dir}/${mod_name}",
    owner   => root,
    group   => root,
    before  => File["__init__.py"]
  }

  file { "_set_overrides.py":
    ensure  => file,
    path    => "${settings}/_set_overrides.py",
    content => "HORIZON_CONFIG['customization_module'] = '${mod_name}.overrides'",
    owner   => root,
    group   => root,
    mode    => 'u+w',
  }

  class { '::cloud::dashboard::overrides::policy':
    require => File["$mod_name"],
  }

  class { '::cloud::dashboard::overrides::hide_deactivated_images':
    require => File["$mod_name"],
  }
}

