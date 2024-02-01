#!/bin/bash

# mv /tmp/apache-zookeeper-3.9.1-bin /users/jason92

cat >> /users/jason92/.bashrc << EOF
export ZOOKEEPER=/users/jason92/apache-zookeeper-3.9.1-bin
export PATH=\$PATH:\$ZOOKEEPER/bin
EOF

cd /users/jason92/apache-zookeeper-3.9.1-bin/conf

cp zoo_sample.cfg zoo.cfg
sed -i -e 's@^dataDir.*@dataDir=/users/jason92/zookeeper@' zoo.cfg

cat >> zoo.cfg << EOF
server.1=jn1:2888:3888
server.2=jn2:2888:3888
server.3=jn3:2888:3888
EOF

mkdir /users/jason92/zookeeper
cd /users/jason92/zookeeper
cat >> myid << EOF
$1
EOF

cd /users/jason92
sudo chmod -R 777 apache-zookeeper-3.9.1-bin
sudo chmod -R 777 zookeeper
