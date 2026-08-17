#!/bin/bash
# $> ./ytdlp_rutube.sh https://rutube.ru/video/deedf3b5a0cc6a126200557512605952/
# парсинг ссылок с помощью yt-dlp

if [[ "$#" -ne 1 ]] || ! [[ "$1" =~ ^('https://rutube.ru/video/') ]]; then
  echo -e "*** \033[31mНет валидной ссылки\033[0m ***" && exit 1
fi

url="$1"
M3U8="playlist_ytdlp_rutube.m3u8"
path_ytdlp="$HOME/bin/./yt-dlp"

rutube_video_info() {
  echo "#EXTM3U" > "$M3U8"
  "$path_ytdlp" --dump-json "$1" | jq -r '.formats.[] | "#EXTINF:-1," + .format_id,.manifest_url'  >> "$M3U8"
}

rutube_video() {
  M3U8_URL=$("$path_ytdlp" -f m3u8-1538-1 --dump-json "$1" \
             | grep -o '"manifest_url": "[^"]*"' | tail -1 | cut -d '"' -f 4)
  echo "$M3U8_URL" 
}

rutube_video_info "$url"
# rutube_video "$url"

