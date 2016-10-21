#!/bin/sh

key=""

#if [ ! -z "$KEYFILE" ]; then
#    key=" --keyFile $KEYFILE --auth"
#else

    if [ -f "/data/keyfile" ]; then
        key=" --keyFile /data/keyfile --auth"
    else
        if [ -f "/etc/mongo/keyfile" ]; then
            key=" --keyFile /etc/mongo/keyfile --auth"
        fi
    fi
#fi


conffile="default.conf"

if [[ "$MODE" == "config" ]]; then
    conffile="configsvr.conf"
    replicationName="configA"
fi

if [[ "$MODE" == "shard" ]]; then
    conffile="shard.conf"
    replicationName="shardA"
fi

if [[ "$MODE" == "mongos" ]]; then
    conffile="mongos.conf"
    replicationName="mongos"
fi


if [ ! -z "$REPLICATION_NAME" ]; then
    replicationName=$REPLICATION_NAME
fi

#cat /etc/mongo/$conffile

if [ -f "/etc/mongo/$conffile" ]; then
    conf="/etc/mongo/$conffile"
fi

if [ -f "/data/$conffile" ]; then
    conf="/data/$conffile"
fi

mkdir /data/logs
mkdir /data/db

echo $conf
echo $key

if [[ "$MODE" == "mongos" ]]; then
    mongos --configdb $CONFIGDB -f $conf $key
else
    sed -i "s/_repl_Set_Name_/${replicationName}/g" $conf

    mongod -f $conf $key
fi
