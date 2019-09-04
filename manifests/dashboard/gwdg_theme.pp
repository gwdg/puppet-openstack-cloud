#
class cloud::dashboard::gwdg_theme (

  $home_dir         = '/usr/share/openstack-dashboard/openstack_dashboard',
  $theme_tar        = 'themes/gwdg_theme.tar',
  $compress_offline = true,

) {

  file { 'gwdg_theme.tar':
    ensure  => file,
    path    => "${home_dir}/themes/gwdg_theme.tar",
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
  }
}
