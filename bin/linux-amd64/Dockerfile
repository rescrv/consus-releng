FROM        ubuntu:14.04
MAINTAINER  robert@consus.io

RUN apt-get update
RUN apt-get install -y gcc g++ make pkg-config python-dev chrpath

ADD build.sh /root/build.sh
ADD compatibility-check /root/compatibility-check
CMD /root/build.sh
