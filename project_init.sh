#!/bin/bash

cd /users/jason92
mkdir projects
cd projects
git clone https://github.com/MengJingsong/hdfs.git
cd hdfs
mkdir xs-files
bash script.sh local-files 0 1000000
