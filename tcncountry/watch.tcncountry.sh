#!/bin/bash

blue="\033[36m"
yellow="\033[1;33m"
normal="\033[0m"

first=$(curl -s "https://watch.tcncountry.net" | grep -oP 'src="/assets/index[^>]+js' | sed 's/src="/https:\/\/watch.tcncountry.net/g')
second=$(curl -s "${first}" | grep -oP 'https://cdn.jwplayer.com/apps/configs/[^>]+",')
third=$(echo "${second}" | sed -n 1p | grep -oP 'https[^>]+son')
echo "${third}"
content=$(curl -s "${third}" | jq '.content')
for item in {0..20}; do 
  title=$(echo "${content}" | jq -r ".["${item}"].title")
  contentId=$(echo "${content}" | jq -r ".["${item}"].contentId")
  if [ "${title}" = 'null' ] && [ "${contentId}" = 'null' ]
    then break
  else 
    if [ "${title}" = 'null' ] || [ "${title}" = "" ] || [ "${contentId}" = 'null' ] || [ "${contentId}" = "" ]
    then continue
    fi
  echo -e "TITLE: ${blue}${title}${normal}, URL: ${yellow}https://watch.tcncountry.net/p/${contentId}${normal}"
  fi
  if [ "${title}" = 'TCN Live' ]
  then live="${contentId}"
  elif [ "${title}" = 'TCN Top 20 Countdown' ]
  then top_countdown="${contentId}"
  fi
done

live_playlist=$(curl -s "https://cdn.jwplayer.com/v2/playlists/${live}" | jq -r '.playlist.[0].sources.[0].file')
echo "#EXTM3U
#EXTINF:-1,TCN Live
${live_playlist}" > playlist.m3u

countdown=$(curl -s "https://cdn.jwplayer.com/v2/playlists/${top_countdown}")
for top in {0..10}
do
top_title=$(echo "${countdown}" | jq -r ".playlist.[${top}].title")
src=$(echo "${countdown}" | jq -r ".playlist.[${top}].sources")
  for number in {0..7}
  do
  if [ $(echo "${countdown}" | jq -r ".playlist.[${top}].sources[${number}].height") = '1080' ]
    then link=$(echo "${countdown}" | jq -r ".playlist.[${top}].sources.[${number}].file")
  fi
  done
echo "#EXTINF:-1,${top_title}
${link}" >> playlist.m3u
done

