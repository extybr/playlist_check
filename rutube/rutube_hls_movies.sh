#!/bin/bash -
# $> ./rutube_hls_movies.sh
# Прямые ссылки rutube.ru

playlist='rutube_films_hls.m3u'
echo "#EXTM3U" > "$playlist"

curl -s 'https://rutube.ru/feeds/movies/' | \
grep -o 'https://rutube.ru/video/[a-z0-9]\{32\}/' | \
sed 's/video/api\/play\/options/g' | \
sort -u | while read url; do
  api_url=$(curl -s "$url")
  echo "$api_url" | yq -r '"#EXTINF:-1, " + .title' >> "$playlist"
  direct_link=$(echo "$api_url" | yq -r '.video_balancer.m3u8')
  curl -s "$direct_link" | tail -n 1 >> "$playlist"
done

