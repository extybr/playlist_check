#!/bin/bash -
# $> ./rutube_movies.sh
# Ссылки rutube.ru

playlist='rutube_movies.m3u'
user_agent='Mozilla/5.0 (X11; Linux x86_64; rv:149.0) Gecko/20100101 Firefox/149.0'

movies=$(curl -s -A "$user_agent" 'https://rutube.ru/feeds/movies/' | \
         grep -oP 'https://rutube.ru/video/[^"]+' | sort -u | awk 'length($0)==57')
if ! [[ -z "$movies" ]]; then
  echo "#EXTM3U" > "$playlist" && echo "$movies" >> "$playlist"
fi

