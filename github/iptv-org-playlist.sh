#!/bin/bash
# $> ./iptv-org-playlist.sh
# $> ./iptv-org-playlist.sh fashion tv
# https://iptv-org.github.io | https://github.com/iptv-org
# Парсит по названию канала/темы и создает плейлист

playlist='iptv-org-playlist.m3u'

result() {
  echo "Playlist created: $1"
  echo "Channels found: $(grep -c '^#EXTINF' $1 2>/dev/null || echo 0)"
}

if [ "$#" -eq 0 ]; then
  curl -s 'https://iptv-org.github.io/api/streams.json' | \
    jq -r '.[] | "#EXTINF:-1," + .title,.url' >> $playlist
  result $playlist && exit
fi

if [ "$#" -gt 2 ]; then
  echo "Usage: $0 <keyword1> [<keyword2>]"
  echo "Example: $0 tv country"
  exit 1
fi

if [ "$#" -eq 1 ]; then
  pattern="$1"
else
  pattern="$1.*$2|$2.*$1"
fi

echo "#EXTM3U" > "$playlist"

curl -s 'https://iptv-org.github.io/api/streams.json' | \
  jq -r ".[] | select(.title | test(\"$pattern\"; \"i\")) | \"#EXTINF:-1,\(.title)\n\(.url)\"" >> $playlist

result $playlist
