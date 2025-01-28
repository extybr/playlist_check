#!/bin/bash
# $> ./101_playlist_without_jq.sh
# WARNING: worst option, without jq 

url='https://101.ru/api/channel/getServers/'

echo '#EXTM3U' > 101_playlist.m3u

for i in {1..10}; do
  response=$(curl -s "https://101.ru/api/channel/getServers/$i")
  title=($(echo "${response}" | grep -oP 'titleChannel[^.]+.'))
  a=$(echo "${title[1]}" | iconv -t utf8 | sed 's/titleChannel":"//g ; s/.$//')
  url=($(echo "${response}" | grep -oP 'urlStream[^\?]+\?'))
  b=$(echo "${url[1]//\\/}" | sed 's/urlStream":"//g ; s/.$//')
  echo -e "${a}\n${b}"
  echo -e "#EXTINF:-1,${a}\n${b}" >> 101_playlist.m3u
done

