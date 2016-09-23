#!/bin/bash
apt-get -y install python-dev libssl-dev libxml2-dev python-setuptools \
                   libmysqlclient-dev libxslt-dev libpq-dev git \
                   libffi-dev gettext build-essential gcc

groupadd --system magnum

useradd --home-dir "/var/lib/magnum" \
        --create-home \
        --system \
        --shell /bin/false \
        -g magnum \
        magnum

mkdir -p /var/log/magnum
mkdir -p /etc/magnum

chown magnum:magnum /var/log/magnum
chown magnum:magnum /var/lib/magnum
chown magnum:magnum /etc/magnum

easy_install -U virtualenv

su -s /bin/sh -c "virtualenv /var/lib/magnum/env" magnum
su -s /bin/sh -c "/var/lib/magnum/env/bin/pip install tox pymysql python-memcached" magnum

# Magnum API/Conductor
cd /var/lib/magnum
git clone https://git.openstack.org/openstack/magnum.git 
cd magnum
git checkout stable/newton
cd ..
chown -R magnum:magnum magnum
cd magnum
su -s /bin/sh -c "/var/lib/magnum/env/bin/pip install -r requirements.txt" magnum
su -s /bin/sh -c "/var/lib/magnum/env/bin/python setup.py install" magnum

su -s /bin/sh -c "cp etc/magnum/policy.json /etc/magnum" magnum
su -s /bin/sh -c "cp etc/magnum/api-paste.ini /etc/magnum" magnum

su -s /bin/sh -c "/var/lib/magnum/env/bin/tox -e genconfig" magnum
su -s /bin/sh -c "cp etc/magnum/magnum.conf.sample /etc/magnum/magnum.conf" magnum

cd /var/lib/magnum/magnum
cp doc/examples/etc/systemd/system/magnum-api.service /etc/systemd/system/magnum-api.service
cp doc/examples/etc/systemd/system/magnum-conductor.service /etc/systemd/system/magnum-conductor.service
cp doc/examples/etc/logrotate.d/magnum.logrotate /etc/logrotate.d/magnum

systemctl enable magnum-api
systemctl enable magnum-conductor

# Magnum Client
curl "https://bootstrap.pypa.io/get-pip.py" -o "/tmp/get-pip.py"
python /tmp/get-pip.py

cd /opt/
git clone https://git.openstack.org/openstack/python-magnumclient.git magnumclient
cd magnumclient
git checkout stable/newton
pip install -r requirements.txt
python setup.py install

## Create Zertification Directory
mkdir -p /var/lib/magnum/certificates/