#!/usr/bin/bash
# $> ./random_film.sh /storage/videos/rutube_retro_films.m3u
# Рамдомный фильм из плейлиста в новый плейлист с прямой ссылкой / Адаптация на Libreelec

# [ -z "$BASH" ] && exec bash "$0" "$@"

PLAYLIST="$1"

if [[ "$#" -ne 1 ]] || ! [[ -f "$PLAYLIST" ]]; then
  exit
fi

NEW_PLAYLIST="$(dirname "$PLAYLIST")/NEW.m3u"
MAX=$(awk 'END{print NR}' "$PLAYLIST")
MIN=3
USER_AGENT='Mozilla/5.0 (X11; Linux x86_64; rv:156.0) Gecko/20100101 Firefox/156.0'

get_direct_link() {
  curl -s --location -A "$USER_AGENT" "$1" | \
  sed -n 's|.*\(https://rutube\.ru/video/[a-z0-9]\{32\}/\).*|\1|p' | \
  sed 's/video/api\/play\/options/g' | \
  sort -u | while read url; do
    api_url=$(curl -s -A "$USER_AGENT" "$url")
    if [[ "$api_url" ]]; then
      echo "#EXTM3U" > "$NEW_PLAYLIST"
      echo -n "#EXTINF:-1, " >> "$NEW_PLAYLIST"
      echo "$api_url" | sed -n 's/.*"title":"\([^"]*\)".*/\1/p' >> "$NEW_PLAYLIST"
      direct_link=$(echo "$api_url" | sed -n 's/.*"m3u8":"\([^"]*\)".*/\1/p' | sed 's/\\u0026/\&/g')
      curl -s -A "$USER_AGENT" "${direct_link}" | tail -n 1 >> "$NEW_PLAYLIST"
    fi
  done
}

newgen() {
  num=$(( $RANDOM % ($MAX - $MIN + 1) + $MIN ))
  if [[ $(( $num % 2  )) -eq 1 ]]; then
    get_direct_link $(sed -n "${num}p" "$PLAYLIST")
    # sed -n "$(( num - 1 ))p" "$PLAYLIST"  # title
    # sed -n "${num}p" "$PLAYLIST"  # url
  else newgen
  fi  
}

if [[ "$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 -A "$USER_AGENT" 'https://rutube.ru/')" == "200" ]]; then
  newgen
fi

