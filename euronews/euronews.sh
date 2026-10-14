#!/bin/bash
# $> ./euronews.sh
# Euronews live playlist generator
# https://www.euronews.com/embed/live

OUT="euronews.m3u"

declare -A CHANNELS=(
  [en]=25002
  [ru]=25071
  [fr]=25026
  [el]=25068
  [hu]=25075
  [it]=25085
  [de]=25027
  [pt]=25040
)

# Порядок вывода в плейлисте
ORDER=(en ru fr el hu it de pt)

declare -A NAMES=(
  [en]="Euronews English"
  [ru]="Euronews Russian"
  [fr]="Euronews French"
  [el]="Euronews Greek"
  [hu]="Euronews Hungarian"
  [it]="Euronews Italian"
  [de]="Euronews German"
  [pt]="Euronews Portuguese"
)

{
  echo "#EXTM3U"
  for lang in "${ORDER[@]}"; do
    id="${CHANNELS[$lang]}"
    name="${NAMES[$lang]:-Euronews $lang}"
    url="https://cdn-euronews.akamaized.net/live/eds/euronews-$lang/$id/index.m3u8"
    echo "#EXTINF:-1 tvg-id=\"euronews-$lang\",$name"
    echo "$url"
  done
} > "$OUT"

echo "Плейлист записан: $OUT"
