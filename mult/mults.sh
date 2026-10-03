#!/bin/bash
# $> ./mults.sh
# Отечественная и зарубежная мультипликация
# Ресурс: https://mults.info

mult() {
  local page=$1
  curl -sf "https://mults.info/mults/?p=${page}&wp=1&by=100" \
    | iconv -f cp1251 -t utf-8 \
    | grep -oP "title=\K[^<]+ jpg" \
    | sed "s|' src='| https://mults.info|g; s|jpg' jpg|mp4|g; s|^.||g; s|screen|mp4|g"
}

for page in {1..40}; do
  mapfile -t items < <(mult "$page")
  ((${#items[@]})) || break

  for str in "${items[@]}"; do
    [[ -z $str ]] && continue
    url="${str##* }"
    title="${str% *}"
    printf '#EXTINF:-1,%s\n%s\n' "$title" "$url"
    printf '#EXTINF:-1,%s\n%s\n' "$title" "$url" >> mults.m3u
  done
  sleep 1
done
