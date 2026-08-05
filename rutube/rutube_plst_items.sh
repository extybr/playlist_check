#!/bin/bash
# $> ./rutube_plst_items.sh https://rutube.ru/plst/349405
# Сериал / сезон, серия (отсортированные по-порядку)

if [ "$#" -eq 1 ] && [[ "$1" =~ ^('https://rutube.ru/plst/') ]]; then
  ID_PLST="${1##*/}"
  PL="playlist_$ID_PLST.m3u8"
  echo "#EXTM3U" > "$PL"
else echo "*** Нет ссылки ***" && exit 0
fi

results() {
  result=$(curl -s "https://rutube.ru/api/playlist/custom/${ID_PLST}/videos?client=wdp&page=${1}&sort=default" | jq 2>/dev/null)
  if [[ "$result" ]]; then
    echo "$result" | jq -r '.results.[] | "#EXTINF:-1, " + .title, "https://rutube.ru/video/" + .id' >> "$PL"
    next=$(echo "$result" | jq -r '.next' 2>/dev/null)
    if ! [[ "$next" == 'null' ]]; then
      results $(( "$1"+1 ))
    else exit 0
    fi
  fi
}

results 1
