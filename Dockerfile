FROM ywx217/docker-webmanage-base:latest
MAINTAINER Wenxuan Yang "ywx217@gmail.com"

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r redis && useradd -r -g redis redis

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
COPY gosu /usr/local/bin/gosu
RUN set -x \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true

ENV REDIS_VERSION 3.2.1

# for redis-sentinel see: http://redis.io/topics/sentinel
COPY redis-3.2.1.tar.gz /tmp/redis.tar.gz
RUN buildDeps='gcc libc6-dev make' \
	&& set -x \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p /usr/src/redis \
	&& tar -xzf /tmp/redis.tar.gz -C /usr/src/redis --strip-components=1 \
	&& rm /tmp/redis.tar.gz \
	&& make -C /usr/src/redis \
	&& make -C /usr/src/redis install \
	&& rm -r /usr/src/redis \
	&& apt-get purge -y --auto-remove $buildDeps

RUN mkdir /data && chown redis:redis /data
VOLUME /data
WORKDIR /data

COPY redis-entrypoint.sh /usr/local/bin/
COPY redis.conf /etc/supervisor/conf.d/redis.conf

EXPOSE 6379

