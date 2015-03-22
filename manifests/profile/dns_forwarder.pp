#
class cloud::profile::dns_forwarder {

  include dns::server

  # Forwarders
  dns::server::options { '/etc/bind/named.conf.options':
    forwarders => ['134.76.10.46', '134.76.33.21'],
  }

  # Forward Zone
  dns::zone { 'cloud.gwdg.de':
    soa         => 'ns1.cloud.gwdg.de',
    soa_email   => 'admin.cloud.gwdg.de',
    nameservers => ['ns1'],
  }

  # Reverse Zone
  dns::zone { '254.1.10.IN-ADDR.ARPA':
    soa         => 'ns1.cloud.gwdg.de',
    soa_email   => 'admin.cloud.gwdg.de',
    nameservers => ['ns1'],
  }

  # A Records:
  dns::record::a {

    # Infrastructure for environment
    'puppetmaster':     zone => 'cloud.gwdg.de',    data => ['10.1.254.2'],     ptr  => true;
    'nfs':              zone => 'cloud.gwdg.de',    data => ['10.1.254.6'],     ptr  => true;
    'rally':            zone => 'cloud.gwdg.de',    data => ['10.1.254.7'],     ptr  => true;
    'ldap':             zone => 'cloud.gwdg.de',    data => ['10.1.254.8'],     ptr  => true;

    # VIPs for loadbalancer (not provisioned)
    # !!! NEEDS CORRECT ZONES !!!
#     'lb-private-vip':   zone => 'cloud.gwdg.de',    data => ['10.1.1.3'],       ptr  => true;
#     'lb-public-vip':    zone => 'cloud.gwdg.de',    data => ['10.1.100.3'],     ptr  => true;

    # HAProxy LBs
    'lb1':              zone => 'cloud.gwdg.de',    data => ['10.1.254.11'],    ptr  => true;
    'lb2':              zone => 'cloud.gwdg.de',    data => ['10.1.254.12'],    ptr  => true;

    # Galera cluster
    'galera1':          zone => 'cloud.gwdg.de',    data => ['10.1.254.21'],    ptr  => true;
    'galera2':          zone => 'cloud.gwdg.de',    data => ['10.1.254.22'],    ptr  => true;

    # MongoDB cluster
    'mongo1':           zone => 'cloud.gwdg.de',    data => ['10.1.254.71'],    ptr  => true;
    'mongo2':           zone => 'cloud.gwdg.de',    data => ['10.1.254.72'],    ptr  => true;
    'mongo3':           zone => 'cloud.gwdg.de',    data => ['10.1.254.73'],    ptr  => true;

    # Controller (+ RabbitMQ)
    'controller1':      zone => 'cloud.gwdg.de',    data => ['10.1.254.31'],    ptr  => true;
    'controller2':      zone => 'cloud.gwdg.de',    data => ['10.1.254.32'],    ptr  => true;

    # Storage nodes
    'storage1':         zone => 'cloud.gwdg.de',    data => ['10.1.254.41'],    ptr  => true;
    'storage2':         zone => 'cloud.gwdg.de',    data => ['10.1.254.42'],    ptr  => true;

    # Network nodes
    'network1':         zone => 'cloud.gwdg.de',    data => ['10.1.254.51'],    ptr  => true;
    'network2':         zone => 'cloud.gwdg.de',    data => ['10.1.254.52'],    ptr  => true;

    # Spof nodes
    'spof1':            zone => 'cloud.gwdg.de',    data => ['10.1.254.61'],    ptr  => true;
    'spof2':            zone => 'cloud.gwdg.de',    data => ['10.1.254.62'],    ptr  => true;

    # Compute nodes
    'compute1':         zone => 'cloud.gwdg.de',    data => ['10.1.254.101'],   ptr  => true;
    'compute2':         zone => 'cloud.gwdg.de',    data => ['10.1.254.102'],   ptr  => true;
    'compute3':         zone => 'cloud.gwdg.de',    data => ['10.1.254.103'],   ptr  => true;

    # Legacy stuff, not sure
    # 10.1.254.8      opentsdb.cloud.gwdg.de

    # Swift (unused)
    # 10.1.254.50     swift-proxy.cloud.gwdg.de
    # 10.1.254.51     swift-proxy-s3.cloud.gwdg.de
    # 10.1.254.60     swift-storage1.cloud.gwdg.de
    # 10.1.254.61     swift-storage2.cloud.gwdg.de
    # 10.1.254.62     swift-storage3.cloud.gwdg.de

  }

}
