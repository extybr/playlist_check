#!/bin/bash
# $> ./rutube_tvprogram.sh https://rutube.ru/live/video/49848b06c0fe2dae124419ffce1a1bab/
# Программа телепередач

if [ "$#" -ne 1 ] || ! [[ "$1" =~ ^(https://rutube.ru/) ]]; then
  echo -e "*** \e[31mНет валидной ссылки\e[0m ***" && exit
fi

VIDEO_ID=$(echo "$1" | grep -o '[a-z0-9]\{32\}')
YMDATE=$(date +%F --date="tomorrow")  # ГГГГ-ММ-ДД

curl -s "http://rutube.ru/pangolin/api/web/tvprogram/${VIDEO_ID}/?programDate=${YMDATE}&client=wdp" \
| jq -r --arg d "$YMDATE" '.result.schedule[$d][] | "\(.title)\t\(.start)\t\(.stop)"' 2>/dev/null \
| while IFS=$'\t' read -r title start stop; do
    echo "$title"
    echo -n 'начало: ' && date -d "@$start" '+%a %d %b %Y %H:%M:%S %:z'
    echo -n 'конец: ' && date -d "@$stop"  '+%a %d %b %Y %H:%M:%S %:z'
  done
