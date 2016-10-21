#!/bin/bash

img=img-mongo-latest.tar
imgname=allen.fantasy/mongo-replication:latest

host1=10.13.27.82
host2=10.13.15.7
host3=10.13.25.241

shard1_port=27011
shard2_port=27012
shard3_port=27013
config_port=27100
mongos_port=27200

if [ -f $img ]; then
    docker load < $img
fi


#create shard1,shard2,shard3 instances of shards and config instance
docker run --name mongo-shard1 -v /data/mongo/shard1:/data -p $shard1_port:27017 -e 'MODE=shard' -e 'REPLICATION_NAME=shard1' -d $imgname

docker run --name mongo-shard2 -v /data/mongo/shard2:/data -p $shard2_port:27017 -e 'MODE=shard' -e 'REPLICATION_NAME=shard2' -d $imgname

docker run --name mongo-shard3 -v /data/mongo/shard3:/data -p $shard3_port:27017 -e 'MODE=shard' -e 'REPLICATION_NAME=shard3' -d $imgname

docker run --name mongo-config -v /data/mongo/config:/data -p $config_port:27017 -e 'MODE=config' -e 'REPLICATION_NAME=config' -d $imgname

docker run --name mongos -v /data/mongo/mongos:/data -p $mongos_port:27017 -e 'MODE=mongos' -e "CONFIGDB=$host1:$config_port,$host2:$config_port,$host3:$config_port" -d $imgname

