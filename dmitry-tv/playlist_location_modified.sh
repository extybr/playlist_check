#!/bin/bash
# $> ./playlist_location_modified.sh Playlist-05.m3u  # с локальным файлом
# $> ./playlist_location_modified.sh http://a0925677.xsph.ru/iptv/Playlist-05.m3u  # с ссылкой на плейлист сайта
# dmi3y-tv.ru -> a0925677.xsph.ru
# Генерирует прямые ссылки

[ "$#" -ne 1 ] && exit

URL="$1"
SRC='loc'

if [[ "${URL}" =~ http://a0925677 ]]; then
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
  if [[ "$line" =~ http://a0925677 ]]; then
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

