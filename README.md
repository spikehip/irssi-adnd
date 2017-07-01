# irssi-adnd

## map.xml 

## building and running 

docker build -t spikehip/irssi-adnd .
docker run -e SERVER_ADDRESS=atw.irc.hu -e CHANNEL_NAME=#coders.hu -e NICK=apatok -ti spikehip/irssi-adnd
