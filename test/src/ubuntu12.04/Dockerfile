FROM        ubuntu:12.04
MAINTAINER  robert@consus.io

RUN apt-get update
RUN apt-get install -y sudo
ADD test_src_common.sh /root/test_src_common.sh
ADD install.sh /root/install.sh

CMD /root/install.sh
