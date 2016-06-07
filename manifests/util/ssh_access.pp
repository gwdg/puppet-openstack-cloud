# Configure ssh keys for access

define cloud::util::ssh_access(

  $home_dir         = undef,

  $user             = undef,
  $group            = undef,

  $public_key_file  = undef,
  $private_key_file = undef,

) {

  file{ "${home_dir}/.ssh":
    ensure  => directory,
    mode    => '0700',
    owner   => $user,
    group   => $group,
  } ->
 
  file{ "${home_dir}/.ssh/id_rsa":
    ensure  => present,
    mode    => '0600',
    owner   => $user,
    group   => $group,
    source  => $private_key_file,
  } ->

  file{ "${home_dir}/.ssh/authorized_keys":
    ensure  => present,
    mode    => '0600',
    owner   => $user,
    group   => $group,
    source  => $public_key_file,
  } ->

  # Disable host key checking so login can be non interactive
  file{ "${home_dir}/.ssh/config":
    ensure  => present,
    mode    => '0600',
    owner   => $user,
    group   => $group,
    content => "
Host *
    StrictHostKeyChecking no
"
  }

}
