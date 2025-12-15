#!/bin/bash
# $> ./films.m3u-update.sh
# Обновление плейлиста FILMS.m3u (https://github.com/Dimonovich/TV)

m3u="$(curl -s 'https://raw.githubusercontent.com/Dimonovich/TV/refs/heads/Dimonovich/FREE/FILMS.m3u')"
films="${SAMSUNG_DIRECTORY}/Desktop/Radio/FILMS.m3u"
if [ "${#m3u}" -gt 100 ]; then
  echo "$m3u" | sed '1p; /#EXTINF:-1 group-title="Новинки кино/,$!d ; /^[[:space:]]*$/{N;/\n[[:space:]]*$/D}' > "$films"
  # sed -i "2i\#EXTINF:-1,         \n$HOME/Видео/Заглушка.mp4" "$films"
fi

