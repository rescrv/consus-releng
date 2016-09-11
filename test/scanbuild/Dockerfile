FROM        ubuntu:14.04
MAINTAINER  robert@consus.io

RUN apt-get update
RUN apt-get install -y clang-3.8 gcc g++ make pkg-config libpopt-dev libgoogle-glog-dev libsparsehash-dev libleveldb-dev python-dev

ADD build.sh /root/build.sh
CMD /root/build.sh
