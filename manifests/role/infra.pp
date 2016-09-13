#
class cloud::role::infra inherits ::cloud::role::base {

    class { '::cloud::profile::dns_forwarder': }
}
