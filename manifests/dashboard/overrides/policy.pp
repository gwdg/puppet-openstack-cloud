class cloud::dashboard::overrides::policy(

  $py_name     = 'policy',
  $policies    = {},
  $policy_path = "${dash_dir}/conf/keystone_policy.json",

) inherits cloud::dashboard::overrides {

  file { "${py_name}.py":
    ensure  => file,
    path    => "${py_dir}/${mod_name}/${py_name}.py",
    source  => 'puppet:///modules/cloud/dashboard/policy.py',
    owner   => root,
    group   => root,
    mode    => 'u+w',
    audit   => content,
  } 

  validate_hash($policies)

  Openstacklib::Policy::Base {
      file_path => $policy_path,
  }

  create_resources('openstacklib::policy::base', $policies)
}

