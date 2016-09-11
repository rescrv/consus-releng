FROM        consusteam/dist
MAINTAINER  robert@consus.io

RUN apt-get update
RUN apt-get install -y libpopt-dev libgoogle-glog-dev
RUN apt-get install -y libsparsehash-dev
ADD build.sh /root/build.sh
CMD /root/build.sh
