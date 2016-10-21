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

echo $conf
sed -i "s/_repl_Set_Name_/${replicationName}/g" $conf

echo "----------------------"
echo $key

echo "----------------------"
#cat $conf

mongod -f $conf $key
