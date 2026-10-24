#!/usr/bin/env bash
# $> ./gods_eye_cameras.sh cache
# $> ./gods_eye_cameras.sh download
# Создание плейлиста со скачиванием базы (cameras.json) локально или в память
# Много камер не рабочих и взяты только url-адреса с m3u8
# Мировые online-камеры / https://github.com/farmino1/Gods_Eye

######### Дополнительно #########
# cat cameras.json | jq -r '.[] | .name,.feed_url'
# cat cameras.json | jq -r '.[] | select(.country == "RU") | .name,.feed_url'
#########
# cat cameras.json | grep 'feed_url' > feed_url.json
# cat cameras.json | grep '.m3u8' > m3u8.json && sed -i 's/"feed_type": "m3u8",//g'
#################################

set -euo pipefail

URL="https://media.githubusercontent.com/media/farmino1/Gods_Eye/refs/heads/main/cameras/cameras.json"
JSON="cameras.json"
OUT="feed_url_m3u8.m3u"

JQ_FILTER='
    .[]
    | select(.feed_url | type == "string" and endswith(".m3u8"))
    | "#EXTINF:-1," + (.name // "без названия"),
      .feed_url
'

download() {
  # скачать локально на комп
  curl -fsS -o "$JSON" "$URL"
  echo "Сохранено локально: $JSON"
  jq -r "\"#EXTM3U\", ($JQ_FILTER)" "$JSON" > "$OUT"
}

cache() {
  # без файла: curl в пайп -> jq -> массив в памяти -> $OUT
  mapfile -t items < <(curl -fsS "$URL" | jq -r "$JQ_FILTER")
  echo "Записей в памяти: ${#items[@]}"
  {
    echo "#EXTM3U"
    printf '%s\n' "${items[@]:-}"
  } > "$OUT"
}

case "${1:-}" in
  cache) cache
  ;;
  download) download
  ;;
  *) echo "Использование: $0 [cache|download]" >&2 && exit 1
  ;;
esac

echo "Готово: $OUT"
echo "Каналов в плейлисте: $(grep -c '^#EXTINF' "$OUT" || true)"
