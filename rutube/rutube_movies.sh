#!/bin/bash -
# $> ./rutube_movies.sh
# Ссылки rutube.ru

playlist='rutube_movies.m3u'
movies=$(curl -s 'https://rutube.ru/feeds/movies/' | grep -oP 'https://rutube.ru/video/[^"]+' | sort -u | awk 'length($0)==57')
if ! [[ -z "$movies" ]]; then
  echo "#EXTM3U" > "$playlist" && echo "$movies" >> "$playlist"
fi

