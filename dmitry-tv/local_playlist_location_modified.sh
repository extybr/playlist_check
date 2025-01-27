#!/bin/bash
# $> ./local_playlist_location_modified.sh Playlist-05.m3u

echo > playlist.m3u
IFS=$'\n'
while read line; do
  if [[ "$line" =~ http://dmi3y-tv ]]; then
    result=$(curl -s --max-time 3 -v --location "$(echo "${line}" | sed 's/.$//')" 2>/dev/null | grep http)
    echo "${result}" >> playlist.m3u
    echo "${result}"
  else echo "${line}" >> playlist.m3u
  fi
done < "$1"

