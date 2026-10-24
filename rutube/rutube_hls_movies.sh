#!/bin/bash -
# $> ./rutube_hls_movies.sh
# $> ./rutube_hls_movies.sh https://rutube.ru/plst/1298438
# $> ./rutube_hls_movies.sh https://rutube.ru/video/2959f7a99504290930cc68951bd2f5ce
# $> ./rutube_hls_movies.sh https://rutube.ru/live/video/c37cd74192c6bc3d6cd6077c0c4fd686
# Прямые ссылки rutube.ru

rutube_url='https://rutube.ru/feeds/movies/'
user_agent='Mozilla/5.0 (X11; Linux x86_64; rv:158.0) Gecko/20100101 Firefox/158.0'

if [ "$#" -eq 1 ]; then
  rutube_url="$1"
fi

playlist="rutube_films_hls_$(date +%s).m3u"
echo "#EXTM3U" > "$playlist"

if [[ "$rutube_url" =~ ^(https://rutube.ru/live/video/) ]]; then
  curl -s --location -A "$user_agent" $(echo "$rutube_url" | sed 's/live\/video/api\/play\/options/g') \
    | jq -r '. | "#EXTINF:-1," + .title,.live_streams.hls.[0].url' > "$playlist"
else
  curl -s --location -A "$user_agent" "$rutube_url" | \
  grep -o 'https://rutube.ru/video/[a-z0-9]\{32\}/' | \
  sed 's/video/api\/play\/options/g' | \
  sort -u | while read url; do
    api_url=$(curl -s -A "$user_agent" "$url")
    if [[ "$api_url" ]]; then
      echo "$api_url" | jq -r '"#EXTINF:-1, " + .title' >> "$playlist"
      echo "$api_url" | jq -r '.title'
      direct_link=$(echo "$api_url" | jq -r '.video_balancer.m3u8')
      curl -s -A "$user_agent" "$direct_link" | tail -n 1 >> "$playlist"
    fi
  done
fi

