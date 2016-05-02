#!/bin/bash

set -e

if [ ! -d /tmp/vagrant-downloads ]; then
    mkdir -p /tmp/vagrant-downloads
fi
chmod a+rw /tmp/vagrant-downloads

if [ -z `which javac` ]; then
    apt-get -y update
    apt-get install -y software-properties-common python-software-properties
    add-apt-repository -y ppa:webupd8team/java
    apt-get -y update
    apt-get -y upgrade

    # Try to share cache. See Vagrantfile for details
    mkdir -p /var/cache/oracle-jdk7-installer
    if [ -e "/tmp/oracle-jdk7-installer-cache/" ]; then
        find /tmp/oracle-jdk7-installer-cache/ -not -empty -exec cp '{}' /var/cache/oracle-jdk7-installer/ \;
    fi

    /bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
    apt-get -y install oracle-java7-installer oracle-java7-set-default

    if [ -e "/tmp/oracle-jdk7-installer-cache/" ]; then
        cp -R /var/cache/oracle-jdk7-installer/* /tmp/oracle-jdk7-installer-cache
    fi
fi

chmod a+rw /opt

if [ ! -e /mnt ]; then
    mkdir /mnt
fi
chmod a+rwx /mnt

pushd /home/vagrant
if [ ! -e spark-1.6.1-bin-hadoop2.4 ]; then
    pushd /tmp/vagrant-downloads
    if [ ! -e spark-1.6.1-bin-hadoop2.4.tgz ]; then
        wget http://a.mbbsindia.com/spark/spark-1.6.1/spark-1.6.1-bin-hadoop2.4.tgz
    fi
    popd

    tar xvzf /tmp/vagrant-downloads/spark-1.6.1-bin-hadoop2.4.tgz
fi
popd

pushd /home/vagrant
if [ ! -e kafka_2.11-0.9.0.1 ]; then
    pushd /tmp/vagrant-downloads
    if [ ! -e kafka_2.11-0.9.0.1.tgz ]; then
        wget http://a.mbbsindia.com/kafka/0.9.0.1/kafka_2.11-0.9.0.1.tgz
    fi
    popd

    tar xvzf /tmp/vagrant-downloads/kafka_2.11-0.9.0.1.tgz
fi
popd

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password mypassword'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password mypassword'
sudo apt-get -y install mysql-server
sudo apt-get -y install libmysql-java


