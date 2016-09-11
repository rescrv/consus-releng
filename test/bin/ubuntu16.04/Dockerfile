FROM        ubuntu:16.04
MAINTAINER  robert@consus.io

RUN apt-get update
RUN apt-get install -y python3 net-tools
ADD test_bin_common.sh /root/test_bin_common.sh
ADD install.sh /root/install.sh
ADD gremlin /usr/bin/gremlin

CMD /root/install.sh
