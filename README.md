# irssi-adnd

[![Build Status](https://travis-ci.org/spikehip/irssi-adnd.svg?branch=master)](https://travis-ci.org/spikehip/irssi-adnd)

A text-based adventure game engine script for irssi.

Define the game map in map.xml along with objects, pre-set characters, their stash, capabilities and actions.

Don't expect too much, this was written in like 2 hours for a gag on irc.

# map.xml structure

Figure it out, pretty straightforward :P

## building and running

docker build -t spikehip/irssi-adnd .

docker run -e SERVER_ADDRESS=atw.irc.hu -e CHANNEL_NAME=#coders.hu -e NICK=apatok -ti spikehip/irssi-adnd
