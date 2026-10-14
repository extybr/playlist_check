#!/bin/bash -
# $> ./rutube_live.sh
# Ссылки online каналов rutube.ru

{
echo "#EXTM3U"
curl -s -A "Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/57.0" 'https://rutube.ru/feeds/live/' \
  | grep -oP 'window\.reduxState[^<]+' \
  | grep -oP '\{"id":"[a-z0-9]{32}".*?"title":"[^"]*"' \
  | sed -n 's/.*"video_url":"\([^"]*\)".*"title":"\([^"]*\)".*/#EXTINF:-1,\2\n\1/p' \
  | awk 'NR%2{title=$0; next} !seen[$0]++{print title; print}'
} > rutube_live.m3u

