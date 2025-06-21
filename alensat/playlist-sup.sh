#!/bin/bash -
# $> ./playlist-sup.sh sup.m3u
# Создание плейлистов по ссылкам плейлистов

if [ "$#" -ne 1 ]; then
  echo "--- необходимо передать ссылку на файл ---"
  exit 0
fi

file_path="$1"
file=$(basename "$file_path")

if [ -f "$file_path" ] && [[ "$file" =~ ^sup ]] && [[ "$file" =~ .m3u$ ]]; then
  folder="${file::-4}"
  cd $(dirname "$file_path")
  mkdir "$folder"
  cd "$folder"
  count=1
  for url in $(cat "../$file" | tail +2); do
    result=$(curl -s --location "$url" 2> /dev/null)
    if [ "$?" = '0' ]; then
      if [[ $(echo "$result" | grep 'http://' 2> /dev/null) ]]; then
        echo "$result" > "${count}.m3u"
      else echo -e "#EXTM3U\n$url" > "${count}.m3u"
      fi
      count=$(( count + 1 ))
    fi
  done
fi

