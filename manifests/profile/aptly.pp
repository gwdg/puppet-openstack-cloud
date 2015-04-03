class cloud::profile::aptly {

  # ----- Setup apache for serving apt repos managed by aptly

  class { 'apache':
    default_mods    => false,
    default_vhost   => false,
    purge_configs   => true,
  }

  apache::vhost { 'puppetmaster.dev.cloud.gwg.de':
    port          => '80',
    docroot       => '/var/lib/aptly/public',
  }
}
