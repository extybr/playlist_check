#!/bin/bash
# ./playlist_check_filepath.sh <путь / файл.m3u>
# Проверка наличия файлов в локального плейлиста

filepath="$1"

if ! [ -f "$filepath" ]; then 
  echo 'Необходимо передать прямой путь файла плейлиста' && exit
fi

cd $(dirname "$filepath")

while read line; do
  # if ! [[ "${line::1}" == '#' ]] && ! [[ "${line::4}" == 'http' ]]; then
  if ! [[ "${line}" =~ ^(#|http) ]]; then
    if ! [ -f "$line" ]; then
      echo "$line not found"
    fi
  fi
done < "$filepath"
