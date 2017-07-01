#!/bin/bash 

sed -i "s/SERVER_ADDRESS/$SERVER_ADDRESS/" /root/.irssi/config
sed -i "s/CHANNEL_NAME/$CHANNEL_NAME/" /root/.irssi/config
sed -i "s/NICK/$NICK/" /root/.irssi/config 

irssi --config /root/.irssi/config --home=/root/.irssi

