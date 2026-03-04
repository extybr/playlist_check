#!/bin/bash -
# $> ./rutube_tags_movies.sh
# Ссылки rutube.ru

playlist='rutube_films.m3u'
echo "#EXTM3U" > "$playlist"

curl -s 'https://rutube.ru/feeds/movies/' | \
grep -o 'https://rutube.ru/api/tags/video/[0-9]\{7\}/' | \
sort -u | while read url; do 
  curl -s "$url" | \
  jq -r '.results[] | "#EXTINF:-1, " + .title, .video_url' >> "$playlist"
done

