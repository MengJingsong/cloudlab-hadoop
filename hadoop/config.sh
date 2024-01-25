#!/bin/bash

mv /tmp/hadoop-$1 /users/jason92

sudo apt-get update
sudo apt-get install -y openjdk-8-jdk

cat >> /users/jason92/.bashrc << EOF
export HADOOP_HOME=/users/jason92/hadoop-$1
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin:\$JAVA_HOME/bin
EOF

source /users/jason92/.bashrc

cd /users/jason92/hadoop-$1/etc/hadoop

grep -o -E 'dn[0-9]+$' /etc/hosts > workers

sed -i '/<configuration>/r /local/repository/hadoop/customized-core' core-site.xml
sed -i '/<configuration>/r /local/repository/hadoop/customized-hdfs' hdfs-site.xml
sed -i '/<configuration>/r /local/repository/hadoop/customized-yarn' yarn-site.xml

sed -i -e 's@^.*export JAVA_HOME.*@export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64@' hadoop-env.sh
sed -i -e 's@^.*export HADOOP_HOME.*@export HADOOP_HOME=/users/jason92/local/hadoop-'$1'@' hadoop-env.sh
sed -i -e 's@^.*export HADOOP_CONF_DIR@export HADOOP_CONF_DIR@' hadoop-env.sh

cd /users/jason92
sudo chmod -R 777 hadoop-$1
