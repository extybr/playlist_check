#!/bin/bash
# $> ./vkvideo_lives.sh

blue="\e[36m"
normal="\e[0m"

user_agent="Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0"
url="https://vkvideo.ru/lives/music"
data="al=1&silent_loading=1"

echo -ne ${blue}
curl -s -A "${user_agent}" -X POST "${url}" -d "${data}" | iconv -f cp1251 | \
grep -oP 'live.vkvideo.ru[^"]+"' | grep -v 'public_video_stream' | \
sed -n '1~4p' | sed 's/live.vkvideo.ru/https:\/\/live.vkvideo.ru/g ; s/\\\\\\//g ; s/.$//'
echo -ne ${normal}

