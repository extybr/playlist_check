#!/bin/bash
# $> ./rutube_list_videos.sh https://rutube.ru/channel/24317262/videos
# $> ./rutube_list_videos.sh https://rutube.ru/video/person/24317262/
# $> ./rutube_list_videos.sh https://rutube.ru/u/mobotixwebcamsrussia
# Плейлист непрямых ссылок в разделе videos на канале пользователя

playlist="rutube_list_videos.m3u"
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:158.0) Gecko/20100101 Firefox/158.0"
URL="https://rutube.ru"

if [[ "$#" -lt 1 ]]; then
  echo 'Нет ссылки' && exit 1
fi

if [[ "$1" =~ ^("$URL/channel/"|"$URL/video/person/") ]]; then
  id=$(echo "$1" | grep -o '[0-9]\{8\}')
elif [[ "$1" =~ ^("$URL/u/") ]]; then
  id=$(curl -s --location -A "$USER_AGENT" "$1" | grep '<title>' | head -1 | grep -o '[0-9]\{8\}')
else echo 'Нет валидной ссылки' && exit 1
fi

page=1
while true; do
  result=$(curl -s "$URL/api/video/person/$id/?client=wdp&origin__type=rtb%2Crst%2Cifrm%2Crspa%2Cvppl&page=$page" \
           -A "$USER_AGENT")
  echo "$result" | jq -r '.results.[] | "#EXTINF:-1," + .title,.video_url' >> "$playlist"
  if [[ $(echo "$result" | jq -r '.has_next') == "false" ]]; then
    break
  fi
  page=$(( $page+1 ))
done
