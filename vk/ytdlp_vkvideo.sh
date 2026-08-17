#!/bin/bash
# $> ./ytdlp_vkvideo.sh "https://vkvideo.ru/video-185112119_456245795"
# парсинг ссылок с помощью yt-dlp

if [[ "$#" -ne 1 ]] || ! [[ "$1" =~ ^('https://vkvideo.ru/video-') ]]; then
  echo -e "*** \033[31mНет валидной ссылки\033[0m ***" && exit 1
fi

url="$1"
M3U8="playlist_ytdlp_vkvideo.m3u8"
path_ytdlp="$HOME/bin/./yt-dlp"

addition() {
  "$path_ytdlp" -g "$1"  # ссылка url потока (не манифест-ссылка)
  "$path_ytdlp" -f hls-1243 -g "$1" # ссылка url потока hls-1243 (не манифест)
  "$path_ytdlp" -F "$1"  # полная информация по форматам аудио и видео потоков
  "$path_ytdlp" --dump-json "$1"  # полная информация в json-формате
}

mpv_play() {
  mpv \
      --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36" \
      --http-header-fields="Referer: https://vkvideo.ru" \
      --hls-bitrate=max \
      --cache=yes \
      --cache-secs=300 \
      --demuxer-max-bytes=10M \
      # "https://vk9-14.vkuser.net/video.m3u8?srcIp=...MY-LONG-LINK"
      # "$(cat playlist_vk.m3u8)"
     "$M3U8"
}

vkvideo_info() {
  "$path_ytdlp" --dump-json "$1" | jq -r '.formats.[] | .format_id,.manifest_url'
}

vkvideo() {
  M3U8_URL=$("$path_ytdlp" -f hls-1243 --dump-json "$1" \
             | grep -o '"manifest_url": "[^"]*"' | tail -1 | cut -d '"' -f 4)
  if [[ "$M3U8_URL" ]]; then
    echo "#EXTM3U" > "$M3U8"
    echo "$M3U8_URL" && echo "$M3U8_URL" >> "$M3U8"
  fi
}

# vkvideo_info "$url"
vkvideo "$url"
# mpv_play

