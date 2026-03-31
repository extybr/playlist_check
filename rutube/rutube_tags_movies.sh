#!/bin/bash -
# $> ./rutube_tags_movies.sh
# Ссылки rutube.ru

playlist='rutube_films.m3u'
user_agent='Mozilla/5.0 (X11; Linux x86_64; rv:149.0) Gecko/20100101 Firefox/149.0'
echo "#EXTM3U" > "$playlist"

curl -s -A "$user_agent" 'https://rutube.ru/feeds/movies/' | \
grep -o 'https://rutube.ru/api/tags/video/[0-9]\{7\}/' | \
sort -u | while read url; do 
  curl -s -A "$user_agent" "$url" | \
  jq -r '.results[] | "#EXTINF:-1, " + .title, .video_url' >> "$playlist"
done

