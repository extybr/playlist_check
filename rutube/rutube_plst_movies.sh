#!/bin/bash -
# $> ./rutube_plst.sh
# Прямые ссылки rutube.ru | Парсинг плейлистов

user_agent='Mozilla/5.0 (X11; Linux x86_64; rv:149.0) Gecko/20100101 Firefox/149.0'
ids=(32181632 33284182 47474626 36046054)

for id in $ids; do 
  curl -s -A "$user_agent" "https://rutube.ru/channel/$id/playlists/" | \
  grep -oP '{"id":[0-9]{6,7},"title":[^+]+","' | \
  sed 's/","/"}/' | jq -r '"https://rutube.ru/plst/\(.id)"' | \
  while read url; do
    echo -e "\n\e[36m$url\e[0m\n"            
    ./rutube_hls_movies.sh "$url"
  done
done

