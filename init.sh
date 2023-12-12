#!/bin/bash

if test -b /dev/sdb && ! grep -q /dev/sdb /etc/fstab; then
  mke2fs -F -j /dev/sdb
  mount /dev/sdb /mnt
  chmod 755 /mnt
  echo "/dev/sdb      /mnt    ext3    defaults,nofail 0       2" >> /etc/fstab
fi

mkdir /mnt/hadoop
chmod 1777 /mnt/hadoop

sudo apt-get update
sudo apt-get install -y openjdk-8-jdk
sudo apt-get install htop

mkdir /users/jason92/local
mv /tmp/hadoop-3.3.0 /users/jason92/local

cat >> /users/jason92/.bashrc << EOF
export HADOOP_HOME=/users/jason92/local/hadoop-3.3.0
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
EOF

source /users/jason92/.bashrc

cd /users/jason92/local/hadoop-3.3.0/etc/hadoop

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
sed -i -e 's@^.*export HADOOP_HOME.*@export HADOOP_HOME=/users/jason92/local/hadoop-3.3.0@' hadoop-env.sh
sed -i -e 's@^.*export HADOOP_CONF_DIR@export HADOOP_CONF_DIR@' hadoop-env.sh

cd /users/jason92/local
sudo chmod -R 777 hadoop-3.3.0

git config --global core.editor "vim"
