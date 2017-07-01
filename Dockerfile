FROM debian
MAINTAINER Andras Bekesi <andras.bekesi@bikeonet.hu>

RUN apt-get update && \
    apt-get -y install build-essential libexpat1 libexpat1-dev cpanminus irssi && \
    cpanm XML::Simple && \
    mkdir -p /root/.irssi/scripts/autorun

COPY adnd.pl /root/.irssi/scripts
COPY map.xml /root/.irssi/scripts
COPY config /root/.irssi/config
COPY run.sh /run.sh

RUN ln -s /root/.irssi/scripts/adnd.pl /root/.irssi/scripts/autorun/adnd.pl

CMD /bin/bash /run.sh 

