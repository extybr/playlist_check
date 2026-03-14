#!/bin/bash -
# $> ./rutube_hls_movies.sh
# $> ./rutube_hls_movies.sh https://rutube.ru/plst/1298438
# Прямые ссылки rutube.ru

rutube_url='https://rutube.ru/feeds/movies/'

if [ "$#" -eq 1 ]; then
  rutube_url="$1"
fi

playlist="rutube_films_hls_$(date +%s).m3u"
echo "#EXTM3U" > "$playlist"

curl -s --location "$rutube_url" | \
grep -o 'https://rutube.ru/video/[a-z0-9]\{32\}/' | \
sed 's/video/api\/play\/options/g' | \
sort -u | while read url; do
  api_url=$(curl -s "$url")
  if [[ "$api_url" ]]; then
    echo "$api_url" | yq -r '"#EXTINF:-1, " + .title' >> "$playlist"
    echo "$api_url" | yq -r '.title'
    direct_link=$(echo "$api_url" | yq -r '.video_balancer.m3u8')
    curl -s "$direct_link" | tail -n 1 >> "$playlist"
  fi
done

