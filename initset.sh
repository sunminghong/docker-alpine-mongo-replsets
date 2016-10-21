#!/bin/bash

img=img-mongo-latest.tar

host1=10.13.27.82
host2=10.13.15.7
host3=10.13.25.241

shard1_port=27011
shard2_port=27012
shard3_port=27013
config_port=27100
mongos_port=27200

#if [ -f $img ]; then
    #docker load < $img
#fi


##create shard1,shard2,shard3 instances of shards and config instance

#docker run --name mongo-shard1 -v /data/mongo/shard1:/data -p $shard1_port:27017 -e 'MODE=shard' -e 'REPLICATION_NAME=shard1' -d allen.fantasy/mongo-replication:latest

#docker run --name mongo-shard2 -v /data/mongo/shard2:/data -p $shard2_port:27017 -e 'MODE=shard' -e 'REPLICATION_NAME=shard2' -d allen.fantasy/mongo-replication:latest

#docker run --name mongo-shard3 -v /data/mongo/shard3:/data -p $shard3_port:27017 -e 'MODE=shard' -e 'REPLICATION_NAME=shard3' -d allen.fantasy/mongo-replication:latest

#docker run --name mongo-config -v /data/mongo/config:/data -p $config_port:27017 -e 'MODE=shard' -e 'REPLICATION_NAME=config' -d allen.fantasy/mongo-replication:latest

#docker run --name mongos -v /data/mongo/mongos:/data -p $mongos_port:27017 -e 'MODE=mongos' -e 'CONFIGDB=$host1:$config_port,$host2:$config_port,$host3:$config_port' -d allen.fantasy/mongo-replication:latest


#configuration shard server replication's nodes

localip=$(/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:")
result=$(echo $localip | grep "${host1}")
if [[ "$result" != "" ]]
then
    serv_no="1"
fi

result=$(echo $localip | grep "${host2}")
if [[ "$result" != "" ]]
then
    serv_no="2"
fi

result=$(echo $localip | grep "${host3}")
if [[ "$result" != "" ]]
then
    serv_no="3"
fi


if [[ $serv_no == "1" ]]; then
echo "
db = connect('${host1}:${shard1_port}/main');
db.getSiblingDB('main');
rs.initiate()
rs.add('${host2}:${shard1_port}')
rs.add('${host3}:${shard1_port}')
" > shard.js

cat shard.js
mongo --nodb shard.js
rm shard.js

#set config replSets
echo "
db = connect('${host1}:${config_port}/main');
db.getSiblingDB('main');
rs.initiate();
rs.add('${host2}:${config_port}');
rs.add('${host3}:${config_port}');
" > config.js

cat config.js
mongo --nodb config.js
rm config.js
fi


if [[ $serv_no == "2" ]]; then
echo "
db = connect('${host2}:${shard2_port}/main');
db.getSiblingDB('main');
rs.initiate();
rs.add('${host1}:${shard2_port}');
rs.add('${host3}:${shard2_port}');
" > shard.js

cat shard.js
mongo --nodb shard.js
rm shard.js
fi


if [[ $serv_no == "3" ]]; then
echo "
db = connect('${host3}:${shard3_port}/main');
db.getSiblingDB('main');
rs.initiate()
rs.add('${host1}:${shard3_port}')
rs.add('${host2}:${shard3_port}')
" > shard.js

cat shard.js
mongo --nodb shard.js
rm shard.js
fi


