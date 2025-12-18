#!/bin/bash
# $> ./m3u_su.sh
# Получаем текст для плейлистов с сайта-агрегатора плейлистов m3u.su

# получаем ссылки
ALL_URLS=()
for number in {1..6}; do
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
  # получаем плейлист
  num=1
  for i in "${ALL_URLS[@]}"; do
    curl -s "$i" | \
    perl -0777 -pe 's/.*?<textarea[^>]*id="m3u-raw"[^>]*>(.*?)<\/textarea>.*/$1/s' | \
    grep -v '^$' > playlist_${num}.m3u
    ((num++))
    sleep 1
    # Проверяем, не пустой ли файл
    if [ -f "playlist_${num}.m3u" ]; then
      lines=$(wc -l < "playlist_${num}.m3u")
      if [ "$lines" -le 10 ]; then
        echo "  Пустой или почти пустой плейлист, удаляю файл..."
        rm "playlist_${num}.m3u"
      else
        echo "  Сохранено: playlist_${num}.m3u ($lines строк)"
      fi
    fi
  done
  echo "Готово! Обработано $((num-1)) URL"
}

get_playlist

