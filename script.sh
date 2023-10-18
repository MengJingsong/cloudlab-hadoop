#!/bin/bash

sudo apt-get update
sudo apt-get install -y openjdk-8-jdk

mkdir /users/jason92/local
sudo mv /tmp/hadoop-3.3.6 /users/jason92/local

cat >> /users/jason92/.bashrc << EOF
export HADOOP_HOME=/users/jason92/local/hadoop-3.3.6
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
EOF

source /users/jason92/.bashrc

cd /users/jason92/local/hadoop-3.3.6/etc/hadoop

cat >> hdfs-site-customize << EOF
  <property>
    <name>dfs.namenode.http-address</name>
    <value>127.0.0.1:50070</value>
  </property>
EOF
sed -i '/<configuration>/r hdfs-site-customize' hdfs-site.xml

cat >> yarn-site-customize << EOF
  <property>
    <name>yarn.resourcemanager.webapp.address</name>
    <value>127.0.0.1:50070</value>
  </property>
EOF
sed -i '/<configuration>/r yarn-site-customize' yarn-site.xml
