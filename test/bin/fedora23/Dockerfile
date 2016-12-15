FROM        fedora:23
MAINTAINER  robert@consus.io

RUN yum install -y tar net-tools

ADD test_bin_common.sh /root/test_bin_common.sh
ADD install.sh /root/install.sh
ADD gremlin /usr/bin/gremlin

CMD /root/install.sh
