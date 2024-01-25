#!/bin/bash

mv /tmp/apache-zookeeper-3.9.1-bin /users/jason92

cat >> /users/jason92/.bashrc << EOF
export ZOOKEEPER=/users/jason92/apache-zookeeper-3.9.1-bin
export PATH=\$PATH:\$ZOOKEEPER/bin
EOF

cd /users/jason92/apache-zookeeper-3.9.1-bin/conf

cp zoo_sample.cfg zoo.cfg
