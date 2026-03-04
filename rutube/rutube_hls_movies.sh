#!/bin/bash -
# $> ./rutube_hls_movies.sh
# Ссылки rutube.ru

playlist='rutube_films_hls.m3u'
echo "#EXTM3U" > "$playlist"

curl -s 'https://rutube.ru/feeds/movies/' | \
grep -o 'https://rutube.ru/video/[a-z0-9]\{32\}/' | \
sed 's/video/api\/play\/options/g' | \
sort -u | while read url; do
  link=$(curl -s "$url")
  echo "$link" | yq -r '"#EXTINF:-1, " + .title' >> "$playlist"
  links=$(echo "$link" | yq -r '.video_balancer.m3u8')
  curl -s "$links" | tail -n 1 >> "$playlist"
done

