# MongoDB Dockerfile
#
# https://github.com/dockerfile/mongodb
#
# MEMOS :
#
# docker build --tag nsrldb:1.0 .
# docker run --name dout7505_NSRL -d nsrldb:1.0
# docker run -it --rm nsrldb:1.0 --help
#
# Pull base image.
FROM mongo:latest

MAINTAINER DOUT7505
COPY installNISTDB.sh /usr/local/bin/installNISTDB.sh
COPY searchMongoDB.pl /usr/local/bin/searchMongoDB.pl
#COPY apt.conf /etc/apt/apt.conf.d/apt.conf
#COPY wgetrc /etc/wgetrc
COPY sysctl.conf /etc/sysctl.conf
RUN chmod a+x /usr/local/bin/*; ln -s /usr/local/bin/searchMongoDB.pl /usr/local/bin/searchMongoDB
RUN sysctl -p

# Install MongoDB.
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends libjson-perl libmongodb-perl && \
  rm -rf /var/lib/apt/lists/*

# Define working directory.
WORKDIR /data

# Define default command.
ENTRYPOINT [ "mongod" ]
CMD ["--noauth"]

# Expose ports.
#   - 27017: process
#   - 28017: http
EXPOSE 27017/tcp
EXPOSE 27018/tcp

