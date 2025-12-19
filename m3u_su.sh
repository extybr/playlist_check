#!/bin/bash
# $> ./m3u_su.sh
# Получаем текст для плейлистов с сайта-агрегатора плейлистов m3u.su

# получаем ссылки
ALL_URLS=()
pmax=$(curl -s 'https://m3u.su' | grep -oP 'href="/page/\K\d+' | tail -1)
for number in $(seq 1 "$pmax"); do
  urls=$(curl -s "https://m3u.su/page/${number}" | grep -o '<a href="/[^"]*/details"' | \
         cut -d'"' -f2 | sed 's|^|https://m3u.su|' | sort -u)
  while IFS= read -r url; do
    if [ -n "$url" ]; then
      ALL_URLS+=("$url")
    fi
  done <<< "$urls"
done
echo "Всего URL: ${#ALL_URLS[@]}"

get_playlist() {
  # получаем плейлисты в цикле
  num=0
  for i in "${ALL_URLS[@]}"; do
    name=$(echo $i | sed 's/https:\/\/m3u.su\/// ; s/\/details//')
    curl -s "$i" | \
    perl -0777 -pe 's/.*?<textarea[^>]*id="m3u-raw"[^>]*>(.*?)<\/textarea>.*/$1/s' | \
    grep -v '^$' > playlist_${name}.m3u
    sleep 1
    # Проверяем, не пустой ли файл
    if [ -f "playlist_${name}.m3u" ]; then
      lines=$(wc -l < "playlist_${name}.m3u")
      if [ "$lines" -le 10 ]; then
        echo "  Пустой или почти пустой плейлист playlist_${name}.m3u, удаляю файл..."
        rm "playlist_${name}.m3u"
      else
        echo "  Сохранено: playlist_${name}.m3u ($lines строк)"
        ((num++))
      fi
    fi
  done
  echo "Готово! Создано $num плейлистов"
}

get_playlist

