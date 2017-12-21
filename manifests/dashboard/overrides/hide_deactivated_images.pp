class cloud::dashboard::overrides::hide_deactivated_images (

  $py_name     = 'hide_deactivated_images',

) inherits cloud::dashboard::overrides {

  file { "${py_name}.py":
    ensure  => file,
    path    => "${py_dir}/${mod_name}/${py_name}.py",
    source  => 'puppet:///modules/cloud/dashboard/hide_deactivated_images.py',
    owner   => root,
    group   => root,
    mode    => 'u+w',
    audit   => content,
  } 

  file { "images_urls.py":
    ensure  => file,
    path    => "${py_dir}/${mod_name}/images_urls.py",
    source  => 'puppet:///modules/cloud/dashboard/images_urls.py',
    owner   => root,
    group   => root,
    mode    => 'u+w',
    audit   => content,
  } 

}

