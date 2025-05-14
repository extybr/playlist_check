#!/bin/bash
# $> ./alensat_playlist.sh
# alensat.com | Print playlist

choice="$1"
page="$2"
dev="&start=$(( $page - 1 ))0"
src='https://alensat.com/viewtopic.php?f'
films="${src}=86&t=287${dev}"   # 425
music="${src}=86&t=2378${dev}"  #162
cookie=$(cat cookie.txt)

if [[ "${choice}" == 'films' ]]; then
  target="${films}"
elif [[ "${choice}" == 'music' ]]; then
  target="${music}"
else exit
fi

echo '﻿#EXTM3U' > alensat_playlist.m3u

curl "${target}" -s --location --proxy localhost:1080 --compressed \
-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:138.0) Gecko/20100101 Firefox/138.0' \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
-H 'Accept-Language: ru,en-US;q=0.7,en;q=0.3' -H 'Accept-Encoding: gzip, deflate, br, zstd' \
-H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' \
-H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1' -H 'Sec-GPC: 1' \
-H 'Priority: u=0, i' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'TE: trailers' \
-H "Cookie: ${cookie}" | \
grep -oP '(#EXTINF|http://)[^<]+' | tail +4 | head -n -9 >> alensat_playlist.m3u

