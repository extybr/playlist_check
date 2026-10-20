#!/bin/bash
# $> ./ytdlp_rutube.sh https://rutube.ru/video/deedf3b5a0cc6a126200557512605952/
# $> ./ytdlp_rutube.sh https://rutube.ru/live/video/c37cd74192c6bc3d6cd6077c0c4fd686/
# парсинг ссылок с помощью yt-dlp

if [[ "$#" -ne 1 ]] || ! [[ "$1" =~ ^('https://rutube.ru/') ]]; then
  echo -e "*** \033[31mНет валидной ссылки\033[0m ***" && exit 1
fi

url="$1"
M3U8="playlist_ytdlp_rutube.m3u8"
path_ytdlp="$HOME/bin/./yt-dlp"

rutube_video_info() {
  echo "#EXTM3U" > "$M3U8"
  "$path_ytdlp" --dump-json "$1" \
    | jq -r '.formats.[] | "#EXTINF:-1," + .format_id,.manifest_url' > "$M3U8"
}

rutube_video() {
  M3U8_URL=$("$path_ytdlp" -f m3u8-1538-1 --dump-json "$1" \
             | grep -oP '"(manifest_url|format_id)": "[^"]*"' \
             | tail -2 | cut -d '"' -f 4 | sed '1 s/^/#EXTINF:-1,/')
  echo "$M3U8_URL" > "$M3U8"
}

if [[ "$1" =~ ^('https://rutube.ru/video/') ]]; then
  rutube_video "$url"
elif [[ "$1" =~ ^('https://rutube.ru/live/video/') ]]; then
  rutube_video_info "$url"
fi
