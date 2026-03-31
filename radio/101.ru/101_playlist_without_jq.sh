#!/bin/bash
# $> ./101_playlist_without_jq.sh
# WARNING: worst option, without jq 

echo '#EXTM3U' > 101_playlist.m3u

url_decode() {
    : "${1//+/ }"
    printf '%b\n' "${_//%/\\x}"
}

for page in {1..10}; do
  curl -s "https://101.ru/api/channel/getServers/$page" | \
  grep -oP '"(titleChannel|urlStream)":\K[^,]+' | \
  tail -2 | \
  while IFS= read -r line; do
    decoded=$(url_decode "$line" | sed 's/\\//g ; s/"//g')
    if [ -n "$decoded" ]; then
      if [[ "$decoded" =~ ^http:// ]]; then
        echo "$decoded"
      else
        echo "#EXTINF:-1,$decoded"
      fi
    fi
  done >> 101_playlist.m3u
done
