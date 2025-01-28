#!/bin/bash
# $> ./101_playlist.sh

url='https://101.ru/api/channel/getServers/'

echo '#EXTM3U' > 101_playlist.m3u

for ((i=1; i<481; i++)); do
  response=$(curl -s "${url}$i")
  (( $(echo "${response}" | jq -r '.status' 2> /dev/null) == 0 )) && continue
  result=$(echo "${response}" | jq -r '.result.[0].titleChannel, .result.[0].urlStream' 2> /dev/null | sed "s/?token.*//g")
  echo "${result}"
  echo "#EXTINF:-1,${result}" >> 101_playlist.m3u
done

