#!/bin/bash -
# $> ./rutube_movies.sh
# Непрямые ссылки rutube.ru / ищет по https://rutube.ru/feeds/movies/

playlist='rutube_movies.m3u'
user_agent='Mozilla/5.0 (X11; Linux x86_64; rv:158.0) Gecko/20100101 Firefox/158.0'

movies=$(curl -s -A "$user_agent" 'https://rutube.ru/feeds/movies/' | \
         grep -oP 'https://rutube.ru/video/[^"]+' | sort -u | awk 'length($0)==57')
if ! [[ -z "$movies" ]]; then
  echo "#EXTM3U" > "$playlist" && echo "$movies" >> "$playlist"
fi

