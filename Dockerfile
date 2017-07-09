FROM debian
MAINTAINER Andras Bekesi <andras.bekesi@bikeonet.hu>

RUN apt-get update && \
    apt-get -y install build-essential libexpat1 libexpat1-dev cpanminus irssi locales && \
    cpanm XML::Simple && \
    adduser --system irssi && \
    localedef -i en_US -f UTF-8 en_US.UTF-8

USER irssi
RUN mkdir -p /home/irssi/.irssi/scripts/autorun

COPY adnd.pl /home/irssi/.irssi/scripts
COPY map.xml /home/irssi/.irssi/scripts
COPY config /home/irssi/.irssi/config
COPY run.sh /home/irssi/run.sh

RUN ln -s /home/irssi/.irssi/scripts/adnd.pl /home/irssi/.irssi/scripts/autorun/adnd.pl

CMD /bin/bash /home/irssi/run.sh
