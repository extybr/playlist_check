#!/bin/bash
# $> ./vkvideo_movies.sh

blue="\e[36m"
normal="\e[0m"

user_agent="Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0"
url="https://vkvideo.ru/movies"

echo -ne ${blue}
for page in MWxs CWxs AWxs FW1Y7 FWVY7 FX1Y7 AW1Y7 AWVY7 AX1Y7; do
  data="al=1&next_from=PUlYVA8${page}&silent_loading=1"
  curl -s -A "${user_agent}" -X POST "${url}" -d "${data}" | iconv -f cp1251 | \
  grep -oP 'video-[^"]+"' | sed 's/video-/https:\/\/vkvideo.ru\/video-/g ; s/..$//'
done
echo -ne ${normal}

