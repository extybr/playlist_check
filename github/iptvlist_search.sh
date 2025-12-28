#!/bin/bash
# $> ./iptvlist_search.sh
# Список плейлистов (в репозитории) для скачивания
# Warning: The API request rate limit for the IP address may have been exceeded

declare -a USER_REPO LIST_DOWNLOAD

USER_REPO=(
ipstreet312/freeiptv
Dimonovich/TV
loganettv/playlists
Spirt007/Tvru
Rafail1082GitHUB/rafail1982.ru
smolnp/IPTVru
Free-TV/IPTV
VokkaOnline/VokkaPlaylist
redmi9cnfc/TV
NoviyKanal/iptvm3u
Spirt007/Tvru
)

LIST_DOWNLOAD=()

for list in "${USER_REPO[@]}"; do
  name_url=$(curl -s "https://api.github.com/repos/$list/contents/" | \
             jq -r ".[] | select(.name | test(\".m3u\"; \"i\")) | \"\(.name)\n\(.download_url)\"")
  # выводим список: имя файла - ссылка для скачивания
  echo -e "$name_url\n"
  # сохраняем список ссылок для скачивания
  mapfile -t links <<< "$(echo "$name_url" | grep -E "^https://raw")"
  LIST_DOWNLOAD+=("${links[@]}")
done

mkdir playlists && cd playlists  # создаем папку для скачивания плейлистов

# скачиваем полученный список плейлистов
for url in "${LIST_DOWNLOAD[@]}"; do
  wget "$url"
  sleep 0.5
done

