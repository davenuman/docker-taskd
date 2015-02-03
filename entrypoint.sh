#!/bin/bash

TASKDHOST=taskd

if [ ! -f "${TASKDDATA}/config" ]; then
  echo "Initialization"
  mkdir -p $TASKDDATA
  taskd init
  echo 127.0.0.1 $TASKDHOST >> /etc/hosts
  ping -c1 $TASKDHOST

  echo "Keys & Certificates"
  cd /taskd-build/pki
  ./generate
  cp client.cert.pem $TASKDDATA
  cp client.key.pem  $TASKDDATA
  cp server.cert.pem $TASKDDATA
  cp server.key.pem  $TASKDDATA
  cp server.crl.pem  $TASKDDATA
  cp ca.cert.pem     $TASKDDATA
  taskd config --force client.cert $TASKDDATA/client.cert.pem
  taskd config --force client.key $TASKDDATA/client.key.pem
  taskd config --force server.cert $TASKDDATA/server.cert.pem
  taskd config --force server.key $TASKDDATA/server.key.pem
  taskd config --force server.crl $TASKDDATA/server.crl.pem
  taskd config --force ca.cert $TASKDDATA/ca.cert.pem

  echo "Configuration"
  cd $TASKDDATA/..
  taskd config --force log $PWD/taskd.log
  taskd config --force pid.file $PWD/taskd.pid
  taskd config --force server $TASKDHOST:53589
  taskd config --force client.allow '^task [2-9],^Mirakel [1-9]'
  taskd config --force debug.tls 3

  echo "Complete"
  cd $TASKDDATA
fi

OWNER=$(stat -c '%u' $TASKDDATA/..)
GROUP=$(stat -c '%g' $TASKDDATA/..)
usermod -o -u $OWNER taskd
groupmod -o -g $GROUP taskd
chown -R taskd:taskd $TASKDDATA/..

if [[ "$@" = "" ]]; then
  echo "Starting taskd"
  #exec su -c "taskd server --data $TASKDDATA" taskd
  taskd server --data $TASKDDATA
else
  cd $TASKDDATA
  exec $@
fi

echo "post-exec"
chown -R taskd:taskd $TASKDDATA/..

