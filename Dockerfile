FROM ubuntu:16.04
MAINTAINER jeltje.van.baren@gmail.com
# Based on Dockerfile by Sebastian Uhrig @ DKFZ

# install utilities
RUN apt-get update -y && apt-get install -y \
    wget 

# install samtools
RUN apt-get install -y samtools

#RUN mkdir /opt
WORKDIR /opt

# install STAR
RUN wget -qO- https://github.com/alexdobin/STAR/archive/2.5.4b.tar.gz | \
tar -x -z --strip-components=3 -C /usr/local/bin -f - STAR-2.5.4b/bin/Linux_x86_64_static/STAR

# install arriba
RUN wget -O- https://github.com/suhrig/arriba/releases/download/v0.12.0/arriba_v0.12.0.tar.gz | tar xz

COPY run_arriba /usr/local/bin/run_arriba

ENV THREADS=8

# Data processing occurs at /data
WORKDIR /data

