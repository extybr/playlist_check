#!/bin/bash
# $> ./cbsnews.sh
# https://www.cbsnews.com/live/

urls() {
  curl -s --location 'https://www.cbsnews.com/live/' | grep -oP '"vide(o|o2)":"\K[^"]+m3u8'
}

mapfile -t url < <(urls)

if [[ ${#url[@]} -ge 2 ]]; then
  echo -e "#EXTINF:-1,stream-cbsivideo\n${url[1]}" > cbsnews.m3u
  echo -e "#EXTINF:-1,stream-google\n${url[0]}" >> cbsnews.m3u
else
  curl -s --location 'https://www.cbsnews.com/live/' \
    | grep -oP 'content="\K[^"]+m3u8' | head -1  > cbsnews.m3u
fi

