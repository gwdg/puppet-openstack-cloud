#
class cloud::rsyslog(
    $environment    = "dev",
    $env_num        = 1,
    $graylog_server = undef,
    $graylog_port   = 0000,
    )
{
    $rsys_graylog_conf = @("RSYSCONFIG")
      template(name="os-gelf" type="list") {
      constant(value="{\"version\":\"1.1\",")
      constant(value="\"host\":\"")
      property(name="hostname")
      # set to real environment
      constant(value="\",\"env\":\"${environment}\"")
      # set to real environment number
      constant(value=",\"env_num\":\"${env_num}\"")
      constant(value=",\"long_message\":\"")
      property(name="msg" format="json")
      constant(value="\",\"short_message\":\"")
      property(name="msg" regex.type="ERE" regex.nomatchmode="FIELD" regex.expression="((\\[.*\\])[[:space:]](.*))" regex.submatch="3" format="json")
      constant(value="\",\"pid\":\"")
      property(name="msg" regex.type="ERE" regex.nomatchmode="BLANK" regex.expression="([0-9]+)" regex.submatch="0" format="json")
      constant(value="\",\"req\":\"")
      property(name="msg" regex.type="ERE" regex.nomatchmode="BLANK" regex.expression="(\\[(req-[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}))" regex.submatch="2" format="json")
      constant(value="\",\"loglevel\":\"")
      property(name="msg" regex.type="ERE" regex.nomatchmode="BLANK" regex.expression="((DEBUG|INFO|ERROR|WARNING|CRITICAL))" regex.submatch="1" format="json")
      constant(value="\",\"app\":\"")
      property(name="programname")
      constant(value="\",\"timestamp\":")
      property(name="timereported" dateformat="unixtimestamp")
      constant(value=",\"level\":\"")
      property(name="syslogseverity")
      constant(value="\"}\n")
      }
      action(
      type="omfwd"
      target="${graylog_server}"
      port="${graylog_port}"
      protocol="tcp"
      template="os-gelf"
      TCP_FrameDelimiter="0"
      KeepAlive="on"
      queue.filename="os-graylog-forward"
      queue.size="1000"
      queue.type="LinkedList"
      queue.saveOnShutdown="on"
      )
    | RSYSCONFIG

 rsyslog::snippet { '8-gelf-graylog.conf':
    content => $rsys_graylog_conf
 }
}

