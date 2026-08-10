#!/bin/bash
# $> ./iptv-web.sh DE

if [ "$#" -ne 1 ]; then
  echo -e "Должен быть 1 параметр страны\nПример:\n ./iptv-web.sh DE" && exit 0
fi

country="$1"
playlist="playlist_${country}.m3u8"

declare -a channels=($(curl -s --location "https://iptv-web.app/$country" | grep -oP '" id="\K[^"]+'))

echo '#EXTM3U' > "$playlist"

for ch in "${channels[@]}"; do
  addr=$(curl -s --location "https://iptv-web.app/$country/$ch/" | grep -oP '<meta name="twitter:player:stream" content="\K[^"]+')
  if [[ "$addr" ]]; then
    result="$ch\n$addr"
    echo -e "${result}\n"
    echo -e "#EXTINF:-1,${result}" >> "$playlist"
  fi
  sleep 1
done


