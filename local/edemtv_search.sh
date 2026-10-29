#!/bin/bash
# $> ./edemtv_search.sh
# $> ./edemtv_search.sh /path-to-files/target-folder/
# Рекурсивный поиск ссылок edemtv в файлах текущей папки, вывод уникальных ссылок (для примера на канал 1001), с подсчетом

if [ "$#" -eq 1 ] && [ -d "$1" ]; then
  cd "$1"
fi

# grep -roE 'https?://[^/[:space:]]+/iptv/[^/[:space:]]+/[0-9]{1,9}/index\.m3u8'
# grep -roP 'https?://[A-Za-z0-9.-]+/iptv/[^/\s]+/[0-9]{1,9}/index\.m3u8'
grep -rohP 'https?://[^/\s]+/iptv/[^/\s]+/[0-9]{1,9}/index\.m3u8' \
  | sed -E 's|/[0-9]{1,9}/index\.m3u8$|/1001/index.m3u8|' \
  | sort -u \
  | nl
