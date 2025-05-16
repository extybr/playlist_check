#!/bin/bash
# $> ./alensat_playlist.sh
# alensat.com | Print playlist

choice="$1"
page="$2"
playlist="alensat_${choice}.m3u"
src='https://alensat.com/viewtopic.php?f'
COOKIE=$(cat cookie.txt)

movies="${src}=86&t=287"       # 426
hd="${src}=86&t=6134"          # 50
music="${src}=86&t=2378"       # 162
sport="${src}=86&t=6132"       # 151
discovery="${src}=86&t=6133"   # 127

if [[ "${choice}" == 'movies' ]]; then
  target="${movies}"
elif [[ "${choice}" == 'hd' ]]; then
  target="${hd}"
elif [[ "${choice}" == 'music' ]]; then
  target="${music}"
elif [[ "${choice}" == 'sport' ]]; then
  target="${sport}"
elif [[ "${choice}" == 'discovery' ]]; then
  target="${discovery}"
else echo -e "Допустимые параметры: \033[00;35mmovies, hd, music, sport, discovery" && exit
fi

function request() {
  curl "$1" -s --max-time 10 --location --proxy localhost:1080 --compressed \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:138.0) Gecko/20100101 Firefox/138.0' \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
  -H 'Accept-Language: ru,en-US;q=0.7,en;q=0.3' -H 'Accept-Encoding: gzip, deflate, br, zstd' \
  -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' \
  -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1' -H 'Sec-GPC: 1' \
  -H 'Priority: u=0, i' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'TE: trailers' \
  -H "Cookie: ${COOKIE}" 
}

last_page=$(request "${target}" | grep -oP 'role="button"[^<]+' | \
            grep -Eo '[0-9]+' | sort -n | tail -1)

echo '﻿#EXTM3U' > "${playlist}"

if [ "${page}" -le "${last_page}" ]; then 
  dev="&start=$(( ${page} - 1 ))0"
else dev="&start=$(( ${last_page} - 1 ))0"
fi

request "${target}${dev}" | grep -oP '(#EXTINF|http://)[^<]+' | awk '
  /^#EXTINF/ {
    extinf = $0
    getline url
    if (url ~ /^http/) {
      pairs[++n] = extinf "\n" url
    }
  }
  END {
    for (i = 1; i <= n; i++) {
      print pairs[i]
    }
  }
' \
>> "${playlist}"

echo -e "\033[00;35mСгенерирован файл: \033[00;36m${playlist}"
echo -e "\033[00;35mПоследняя страница: \033[00;36m${last_page}\033[0m"

