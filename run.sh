#!/bin/bash 

sed -i "s/SERVER_ADDRESS/$SERVER_ADDRESS/" /home/irssi/.irssi/config
sed -i "s/CHANNEL_NAME/$CHANNEL_NAME/" /home/irssi/.irssi/config
sed -i "s/NICK/$NICK/" /home/irssi/.irssi/config 

irssi --config /home/irssi/.irssi/config --home=/home/irssi/.irssi

