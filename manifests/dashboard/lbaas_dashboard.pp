class cloud::dashboard::lbaas_dashboard(
){
    package { 'python-neutron-lbaas-dashboard':
      ensure  => 'present',
    }
}
