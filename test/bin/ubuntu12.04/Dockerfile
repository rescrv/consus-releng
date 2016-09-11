FROM        ubuntu:12.04
MAINTAINER  robert@consus.io

RUN apt-get update
RUN apt-get install -y net-tools wget python-software-properties
RUN add-apt-repository ppa:fkrull/deadsnakes
RUN apt-get update
RUN apt-get install -y python3.3
RUN ln -s /usr/bin/python3.3 /usr/bin/python3
RUN rm /etc/apt/sources.list.d/fkrull-deadsnakes-precise.list
RUN apt-get update
ADD test_bin_common.sh /root/test_bin_common.sh
ADD install.sh /root/install.sh
ADD gremlin /usr/bin/gremlin

CMD /root/install.sh
