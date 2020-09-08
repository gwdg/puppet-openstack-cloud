#
class cloud::rsyslog(
    $environment    = "dev",
    $env_num        = 1,
    $graylog_server = undef,
    $graylog_port   = 0000,
    )
{
 rsyslog::snippet { '8-gelf-graylog.conf':
    content => template('cloud/gelf-graylog.conf.erb')
 }
}

