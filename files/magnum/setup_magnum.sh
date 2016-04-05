#!/bin/bash

# Install Git
apt-get -y install git

# Install Pip
curl "https://bootstrap.pypa.io/get-pip.py" -o "/tmp/get-pip.py"
python /tmp/get-pip.py

# Install Magnum Api/Conductor
git clone https://github.com/openstack/magnum.git /opt/magnum
cd /opt/magnum
git checkout tags/2.0.0
apt-get -y install build-essential libssl-dev libffi-dev python-dev
pip install -e .

# Install Magnum Client
git clone https://git.openstack.org/openstack/python-magnumclient /opt/magnumclient
cd /opt/magnumclient
git checkout tags/2.0.0
sudo pip install -e .

# Generate Base Config
pip install tox
cd /opt/magnum/etc/magnum
tox -egenconfig

mkdir /etc/magnum
cp /opt/magnum/etc/magnum/magnum.conf.sample /etc/magnum/magnum.conf
cp /opt/magnum/etc/magnum/policy.json /etc/magnum/policy.json
cp /opt/magnum/etc/magnum/api-paste.ini /etc/magnum/api-paste.ini

# Create Zertification Directory
mkdir -p /var/lib/magnum/certificates/

#Create Magnum Services
cat > /etc/init/magnum-api.conf << EOF
description "Magnum API"
author "Maik Srba <maik.srba@gwdg.de>"

start on runlevel [2345]
stop on runlevel [!2345]

chdir /var/run

respawn
respawn limit 20 5
limit nofile 65535 65535

pre-start script
    for i in lock run log lib ; do
        mkdir -p /var/$i/magnum
        #chown magnum /var/$i/magnum
    done
end script

script
    [ -x "/usr/local/bin/magnum-api" ] || exit 0
    DAEMON_ARGS=""
    [ -r /etc/default/openstack ] && . /etc/default/openstack
    [ -r /etc/default/$UPSTART_JOB ] && . /etc/default/$UPSTART_JOB
    [ "x$USE_SYSLOG" = "xyes" ] && DAEMON_ARGS="$DAEMON_ARGS --use-syslog"
    [ "x$USE_LOGFILE" != "xno" ] && DAEMON_ARGS="$DAEMON_ARGS --log-file=/var/log/magnum/magnum-api.log"

    exec start-stop-daemon --start --chdir /var/lib/magnum \
        --chuid root:root --make-pidfile --pidfile /var/run/magnum/magnum-api.pid \
        --exec /usr/local/bin/magnum-api -- --config-file=/etc/magnum/magnum.conf ${DAEMON_ARGS}
end script
EOF

cat > /etc/init/magnum-conductor.conf << EOF
description "Magnum Conductor"
author "Maik Srba <maik.srba@gwdg.de>"

start on runlevel [2345]
stop on runlevel [!2345]

chdir /var/run

respawn
respawn limit 20 5
limit nofile 65535 65535

pre-start script
    for i in lock run log lib ; do
        mkdir -p /var/$i/magnum
        #chown magnum /var/$i/magnum
    done
end script

script
    [ -x "/usr/local/bin/magnum-conductor" ] || exit 0
    DAEMON_ARGS=""
    [ -r /etc/default/openstack ] && . /etc/default/openstack
    [ -r /etc/default/$UPSTART_JOB ] && . /etc/default/$UPSTART_JOB
    [ "x$USE_SYSLOG" = "xyes" ] && DAEMON_ARGS="$DAEMON_ARGS --use-syslog"
    [ "x$USE_LOGFILE" != "xno" ] && DAEMON_ARGS="$DAEMON_ARGS --log-file=/var/log/magnum/magnum-conductor.log"

    exec start-stop-daemon --start --chdir /var/lib/magnum \
        --chuid root:root --make-pidfile --pidfile /var/run/magnum/magnum-conductor.pid \
        --exec /usr/local/bin/magnum-conductor -- --config-file=/etc/magnum/magnum.conf ${DAEMON_ARGS}
end script
EOF