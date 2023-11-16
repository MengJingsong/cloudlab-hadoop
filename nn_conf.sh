#!/bin/bash

cd /users/jason92/local/hadoop-3.3.6/etc/hadoop

grep -o -E 'slave[0-9]+$' /etc/hosts > workers

cat >> core-site-customize << EOF
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://namenode:9000</value>
  </property>
  <property>
    <name>hadoop.tmp.dir</name>
    <value>/mnt/hadoop/hadoop-jason92</value>
  </property>
EOF
sed -i '/<configuration>/r core-site-customize' core-site.xml

cat >> hdfs-site-customize << EOF
  <property>
    <name>dfs.namenode.http-address</name>
    <value>127.0.0.1:50070</value>
  </property>
EOF
sed -i '/<configuration>/r hdfs-site-customize' hdfs-site.xml

cat >> yarn-site-customize << EOF
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
sed -i '/<configuration>/r yarn-site-customize' yarn-site.xml

cat >> mapred-site-customize << EOF
  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>
  <property>
    <name>mapreduce.jobhistory.webapp.address</name>
    <value>127.0.0.1:19888</value>
  </property>
EOF
sed -i '/<configuration>/r mapred-site-customize' mapred-site.xml

sed -i -e 's@^.*export JAVA_HOME.*@export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64@' hadoop-env.sh
sed -i -e 's@^.*export HADOOP_HOME.*@export HADOOP_HOME=/users/jason92/local/hadoop-3.3.6@' hadoop-env.sh
sed -i -e 's@^.*export HADOOP_CONF_DIR@export HADOOP_CONF_DIR@' hadoop-env.sh
