#!/bin/bash
# $> ./rutube_broadcasts_by_topic.sh all
# $> ./rutube_broadcasts_by_topic.sh
# ТВ-эфиры rutube по тематикам

URL="https://rutube.ru/api/feeds/autowidget/2?client=wdp"
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:158.0) Gecko/20100101 Firefox/158.0"
PLAYLIST="rutube_broadcasts_by_topic.m3u"

RESULT=$(curl -s -A "$USER_AGENT" "$URL" | jq)

request() {
  echo $RESULT | jq -r "$1"
}

MAX_PAGE=$(request ".results | length")

if [ "$#" -eq 1 ] && [[ "$1" == "all" ]]; then
  # Все прямые эфиры / с непрямыми url-ссылками
  echo "#EXTM3U" > "all_$PLAYLIST"
  request ".results.[0].childs.[] | \"#EXTINF:-1,\" + .title,.video_url" >> "all_$PLAYLIST"
  echo "✅ Готово: all_$PLAYLIST" && exit
fi

# по тематикам
echo "#EXTM3U" > "$PLAYLIST"
for ((ch=1; ch<MAX_PAGE; ch++)); do
  group_title=$(request ".results.[$ch].name")
  request ".results.[$ch].childs.[] | \"#EXTINF:-1 group-title=\\\"${group_title}\\\" tvg-logo=\\\"\" + .thumbnail_url + \"\\\", \" + .title,.video_url" >> "$PLAYLIST"
done

# получение прямых ссылок с заменой
while read url; do
  if [[ "$url" =~ ^('https://rutube') ]]; then
    new_url=$(curl -s -A "$USER_AGENT" $(echo "$url" | sed 's/live\/video/api\/play\/options/g') \
              | jq -r '.live_streams.hls.[0].url')
    if [[ "$new_url" != 'null' ]]; then
      esc_re()  { printf '%s' "$1" | sed -e 's/[][\.^$*+?(){}|/]/\\&/g'; }
      esc_rep() { printf '%s' "$1" | sed -e 's/[&\\|]/\\&/g'; }
      sed -i "s|$(esc_re "$url")|$(esc_rep "$new_url")|g" "$PLAYLIST"
    else
      url_esc=$(printf '%s' "$url" | sed 's/[.[\*^$|]/\\&/g')
      sed -i -e '/^#EXTINF/{' -e 'N' -e "\|$url_esc|d" -e '}' "$PLAYLIST"
      echo " ^... Неактивный или платный канал ❌"
    fi
    sleep 1
  else echo "${url#*,}"
  fi
done < "$PLAYLIST"

echo -e "\n✅ Готово: $PLAYLIST"

