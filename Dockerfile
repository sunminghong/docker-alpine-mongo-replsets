FROM alpine:edge
#FROM allen.fantasy/alpine:edge

MAINTAINER allen <allen.fantasy@gmail.com>

RUN apk add --no-cache mongodb
ADD startmongo.sh /sbin/
RUN chmod +x /sbin/startmongo.sh


RUN mkdir /etc/mongo
ADD configsvr.conf /etc/mongo/
ADD shard.conf /etc/mongo/
ADD default.conf /etc/mongo/



VOLUME /data
EXPOSE 27017
 #28017

ENTRYPOINT ["startmongo.sh"]

#CMD ["startmongo.sh"]
