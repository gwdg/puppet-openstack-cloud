#
class cloud::dashboard::gwdg_theme (

  $home_dir         = '/usr/share/openstack-dashboard/openstack_dashboard/',
  $add_theme        = 'local/local_settings.d/_set_custom_theme_gwdg.py',
  $quota_scss       = 'static/dashboard/scss/components/_quota.scss',
  $gwdg_logo        = 'static/dashboard/img/gwdg_logo.svg',
  $theme_tar        = 'themes/gwdg_theme.tar',
  $compress_offline = true,

) {

  file { '_set_custom_theme_gwdg.py':
    ensure  => file,
    path    => "${home_dir}${add_theme}",
    source  => 'puppet:///modules/cloud/dashboard/_set_custom_theme_gwdg.py',
    owner   => root,
    group   => root,
    mode    => 'u+w',
    audit   => content,
  } 

  file { 'gwdg_logo.svg':
    ensure  => file,
    path    => "${home_dir}${gwdg_logo}",
    source  => 'puppet:///modules/cloud/dashboard/gwdg_logo.svg',
    owner   => root,
    group   => root,
    mode    => 'u+w',
    audit   => content,
  } 

  file { 'gwdg_theme.tar':
    ensure  => file,
    path    => "${home_dir}${theme_tar}",
    source  => 'puppet:///modules/cloud/dashboard/gwdg_theme.tar',
    owner   => root,
    group   => root,
    mode    => 'u+w',
    audit   => content,
    before  => Exec['tar -xf gwdg_theme.tar'],
  } 

  exec { 'tar -xf gwdg_theme.tar':
    path => '/bin:/usr/bin:/sbin:/usr/sbin:',
    unless   => 'test -f /usr/share/openstack-dashboard/openstack_dashboard/themes/gwdg/',
    cwd      => '/usr/share/openstack-dashboard/openstack_dashboard/themes/',
    command  => 'tar xf gwdg_theme.tar',
    creates  => '/usr/share/openstack-dashboard/openstack_dashboard/themes/gwdg/',
  }

  if $compress_offline {
    Exec['tar -xf gwdg_theme.tar'] ~> Exec['refresh_horizon_django_compress']
    File['gwdg_logo.svg'] ~> Exec['refresh_horizon_django_compress']
    File['_set_custom_theme_gwdg.py'] ~> Exec['refresh_horizon_django_compress']
  }
}

