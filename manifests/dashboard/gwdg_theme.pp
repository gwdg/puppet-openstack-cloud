#
class cloud::dashboard::gwdg_theme (

  $home_dir         = '/usr/share/openstack-dashboard/openstack_dashboard',
  $static_dir       = '/var/lib/openstack-dashboard',
  $theme_tar        = 'themes/gwdg_theme_13052020.tar',
  $compress_offline = true,

) {

  file { 'gwdg_theme':
    ensure  => file,
    path    => "${home_dir}/themes/gwdg_theme_13052020.tar",
    source  => 'puppet:///modules/cloud/dashboard/gwdg_theme_13052020.tar',
    owner   => root,
    group   => root,
    mode    => 'u+w',
    audit   => content,
    before  => Exec['tar_gwdg_theme'],
  } 

  exec { 'tar_gwdg_theme':
    path => '/bin:/usr/bin:/sbin:/usr/sbin:',
    unless   => 'test -f /usr/share/openstack-dashboard/openstack_dashboard/themes/gwdg/',
    cwd      => '/usr/share/openstack-dashboard/openstack_dashboard/themes/',
    command  => 'tar xf  gwdg_theme_13052020.tar --overwrite',
    #creates  => '/usr/share/openstack-dashboard/openstack_dashboard/themes/gwdg/',
  }

  file {'gwdg_logo_img':
    ensure  => file,
    path    => "${static_dir}/static/dashboard/img/logo-splash.svg",
    source  => "${home_dir}/themes/gwdg/templates/gwdg/logo-splash.svg",
    owner   => root,
    group   => root,
    mode    => 'u+w',
    audit   => content,
    subscribe => Exec['tar_gwdg_theme'],
  }

  file {'gwdg_brand_ico':
    ensure  => file,
    path    => "${static_dir}/static/dashboard/img/favicon.ico",
    source  => "${home_dir}/themes/gwdg/templates/gwdg/favicon.ico",
    owner   => root,
    group   => root,
    mode    => 'u+w',
    audit   => content,
    subscribe => Exec['tar_gwdg_theme'],
  }

  if $compress_offline {
    Exec['tar_gwdg_theme'] ~> Exec['refresh_horizon_django_compress']
  }
}
