#!/bin/bash -
# $> ./rutube_plst.sh
# Прямые ссылки rutube.ru | Парсинг плейлистов

ids=(32181632 33284182 47474626 36046054)

for id in $ids; do 
  curl -s "https://rutube.ru/channel/$id/playlists/" | \
  grep -oP '{"id":[0-9]{6,7},"title":[^+]+","' | \
  sed 's/","/"}/' | jq -r '"https://rutube.ru/plst/\(.id)"' | \
  while read url; do
    echo -e "\n\e[36m$url\e[0m\n"            
    ./rutube_hls_movies.sh "$url"
  done
done

