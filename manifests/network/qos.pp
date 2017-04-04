#
# Network qos
#
# === Parameters
# 
# [*policies*]
#  (optional) Hash of the neutron policies to enable
#  Example:
#  policies = {
#    'my_policy' => {
#      'max_kbps' => 100000,
#      'max_burst_kbps' => '80000'
#    }
#  }
#  Defaults to undef
#
class cloud::network::qos(
  $policies = undef,
  $os_project_name = 'admin',
  $os_username     = 'admin',
  $os_password,   
  $os_auth_url     = 'http://127.0.0.1:5000/v2.0/',
) {

  include ::cloud::network

  if $policies {
    create_resources('::cloud::network::qos::create', $policies)
  }

  Cloud::Network::Qos::Create <| |> {
    os_project_name => $os_project_name,
    os_username     => $os_username,
    os_password     => $os_password,
    os_auth_url     => $os_auth_url
  }
}
