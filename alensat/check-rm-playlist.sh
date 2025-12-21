#!/bin/bash -
# $> ./check-rm-playlist.sh
# Проверяет все плейлисты в папке.
# Проверка по первой ссылке, если ссылка недоступна или присутствует определенный
# паттерн заглушки или ошибка по времени задержки, то плейлист удаляется.
# TODO: Для определенных плейлистов. С использованием временного файла.

for i in *.m3u; do
  if [[ -f "$i" ]]; then
    url=$(grep -m1 'http://' "$i" 2>/dev/null | tr -d '\r\n')
    if [[ -n "$url" ]]; then
      # Создаем временный файл для вывода curl
      temp_file=$(mktemp)
      curl_exit=0

      # Выполняем curl и сохраняем код возврата
      curl -s --max-time 10 --location "$url" > "$temp_file" 2>&1 || curl_exit=$?

      # Проверяем содержимое и код возврата
      if grep -Eq '(/404/|BanT0ken)' "$temp_file" || \
      [[ $curl_exit -eq 6 ]] || \
      [[ $curl_exit -eq 7 ]] || \
      [[ $curl_exit -eq 28 ]]; then
        echo "Удаляем $i (код: $curl_exit)" && rm "$i"
      else
        echo "$i - OK"
      fi

      # Удаляем временный файл
      rm -f "$temp_file"
    else
      echo "Удаляем $i - NO URL" && rm "$i"
    fi
  fi
done

