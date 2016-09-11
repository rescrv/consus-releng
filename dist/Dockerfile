FROM        ubuntu:14.04
MAINTAINER  robert@consus.io

RUN apt-get update
RUN apt-get install -y gcc g++ make pkg-config m4 xz-utils gperf flex bison python-dev python-pip pandoc help2man valgrind

COPY autoconf-2.69.tar.gz /root/autoconf-2.69.tar.gz
COPY automake-1.15.tar.gz /root/automake-1.15.tar.gz
COPY libtool-2.4.6.tar.gz /root/libtool-2.4.6.tar.gz
COPY autoconf-archive-2015.02.24.tar.xz /root/autoconf-archive-2015.02.24.tar.xz

WORKDIR /tmp
RUN tar xzf /root/autoconf-2.69.tar.gz
RUN tar xzf /root/automake-1.15.tar.gz
RUN tar xzf /root/libtool-2.4.6.tar.gz
RUN tar xJf /root/autoconf-archive-2015.02.24.tar.xz
WORKDIR /tmp/autoconf-2.69
RUN ./configure --prefix=/usr && make && make install
WORKDIR /tmp/automake-1.15
RUN ./configure --prefix=/usr && make && make install
WORKDIR /tmp/libtool-2.4.6
RUN ./configure --prefix=/usr && make && make install
WORKDIR /tmp/autoconf-archive-2015.02.24
RUN ./configure --prefix=/usr && make && make install
WORKDIR /
RUN pip install cython
COPY gremlin /usr/bin/gremlin
