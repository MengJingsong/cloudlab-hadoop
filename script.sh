#!/bin/bash

sudo apt-get update
sudo apt-get install -y openjdk-8-jdk

mkdir /users/jason92/local
sudo mv /tmp/hadoop-3.3.6 /users/jason92/local

cat >> /users/jason92/.bashrc << EOF
export HADOOP_HOME=/users/jason92/local/hadoop-3.3.6
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
EOF

source /users/jason92/.bashrc

cd /users/jason92/local/hadoop-3.3.6/etc/hadoop

sudo cat >> core-site-customize << EOF
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://namenode:9000</value>
  </property>
EOF
sudo sed -i '/<configuration>/r core-site-customize' core-site.xml

sudo cat >> hdfs-site-customize << EOF
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>/users/jason92/hadoop/data/namenode</value>
  </property>
  <property>
    <name>dfs.namenode.data.dir</name>
    <value>/users/jason92/hadoop/data/datanode</value>
  </property>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>
  <property>
    <name>dfs.namenode.http-address</name>
    <value>127.0.0.1:50070</value>
  </property>
EOF
sudo sed -i '/<configuration>/r hdfs-site-customize' hdfs-site.xml

sudo cat >> yarn-site-customize << EOF
  <property>
    <name>yarn.acl.enable</name>
    <value>0</value>
  </property>
  <property>
    <name>yarn.resourcemanager.hostname</name>
    <value>resourcemanager</value>
  </property>
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>
  <property>
    <name>yarn.resourcemanager.webapp.address</name>
    <value>127.0.0.1:50070</value>
  </property>
EOF
sudo sed -i '/<configuration>/r yarn-site-customize' yarn-site.xml

sudo cat >> mapred-site-customize << EOF
  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>
  <property>
    <name>mapreduce.jobhistory.webapp.address</name>
    <value>127.0.0.1:19888</value>
  </property>
EOF
sudo sed -i '/<configuration>/r mapred-site-customize' mapred-site.xml
