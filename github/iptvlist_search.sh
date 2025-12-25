#!/bin/bash
# $> ./iptvlist_search.sh
# Список плейлистов (в репозитории) для скачивания
# Warning: The API request rate limit for the IP address may have been exceeded

declare -a USER_REPO LIST_DOWNLOAD

USER_REPO=(
ChiSheng9/iptv
ipstreet312/freeiptv
Dimonovich/TV
loganettv/playlists
Spirt007/Tvru
Rafail1082GitHUB/rafail1982.ru
smolnp/IPTVru
Free-TV/IPTV
)

LIST_DOWNLOAD=()

for list in "${USER_REPO[@]}"; do
  name_url=$(curl -s "https://api.github.com/repos/$list/contents/" | \
             jq -r ".[] | select(.name | test(\".m3u\"; \"i\")) | \"\(.name)\n\(.download_url)\"")
  # выводим список: имя файла - ссылка для скачивания
  echo -e "$name_url\n"
  # сохраняем список ссылок для скачивания
  LIST_DOWNLOAD+=$(echo "${name_url}" | grep -E "^https://raw")
done

LIST_DOWNLOAD=$(echo $LIST_DOWNLOAD | sed "s/ /\\n/g")  # удаляем пробел между списками

mkdir playlists && cd playlists  # создаем папку для скачивания плейлистов

# скачиваем полученный список плейлистов
while read url; do
  curl -O "$url"
done <<< "$LIST_DOWNLOAD"

cd ..  # выход из папки

