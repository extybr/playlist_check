#!/bin/bash
# $> ./iptv-org-playlist.sh fashion tv
# https://iptv-org.github.io | https://github.com/iptv-org
# Парсит по названию канала и создает плейлист

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: $0 <keyword1> [<keyword2>]"
  echo "Example: $0 tv country"
  exit 1
fi

playlist='iptv-org-playlist.m3u'

if [ "$#" -eq 1 ]; then
  pattern="$1"
else
  pattern="$1.*$2|$2.*$1"
fi

echo "#EXTM3U" > "$playlist"

curl -s 'https://iptv-org.github.io/api/streams.json' | \
  jq -r ".[] | select(.title | test(\"$pattern\"; \"i\")) | \"#EXTINF:-1,\(.title)\n\(.url)\"" >> $playlist

echo "Playlist created: $playlist"
echo "Channels found: $(grep -c '^#EXTINF' $playlist 2>/dev/null || echo 0)"
