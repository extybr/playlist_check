#!/bin/bash
# $> ./tvrain.sh

echo -e "#EXTM3U\n#EXTINF:-1, Дождь
$(curl -s --location 'https://tvrain.tv/live' | grep -oP '\"contentUrl\": "\K[^\"]+')
#EXTINF:-1,twitch TVRainchannel / latest video
https://www.twitch.tv/tvrainchannel/videos" > tvrain.m3u8

