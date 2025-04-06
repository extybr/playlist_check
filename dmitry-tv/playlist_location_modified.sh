#!/bin/bash
# $> ./playlist_location_modified.sh Playlist-05.m3u
# $> ./playlist_location_modified.sh http://dmi3y-tv.ru/iptv/Playlist-05.m3u

[ "$#" -ne 1 ] && exit

URL="$1"
SRC='loc'

if [[ "${URL}" =~ http://dmi3y-tv ]]; then
  URL=$(curl -s "${URL}")
  header=$(echo "${URL}" | sed -n '1,+4p')
  echo "${header}" > playlist.m3u
  SRC="nonloc"
elif [ -f "${URL}" ]; then
  sed -n '1,+4p' "${URL}" > playlist.m3u
else exit
fi

IFS=$'\n'
while read line; do
  if [[ "$line" =~ http://dmi3y-tv ]]; then
    result=$(curl -s --max-time 3 -v --location "${line:0:-1}" 2>/dev/null | grep http)
    echo "${result}" >> playlist.m3u
    echo "${result}"
  else echo "${line}" >> playlist.m3u
  fi
done < <(if [ "${SRC}" = 'loc' ]; then
         sed -n '6,$p' "${URL}"
         elif [ "${SRC}" = 'nonloc' ]; then
         echo "${URL}" | sed -n '6,$p'
         fi)

sed -i '/cdn\.ngenix\.net/{N;d;}' playlist.m3u

