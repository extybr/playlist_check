#!/bin/bash
# $> ./vkvideo_movies.sh

blue="\e[36m"
normal="\e[0m"

user_agent="Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0"
url="https://vkvideo.ru/movies"

echo -e '#EXTM3U' > playlist.m3u

list='MWxs CWxs AWxs FW1Y7 FWVY7 FX1Y7 AW1Y7 AWVY7 AX1Y7'

echo -ne "${blue}"
for page in ${list[@]}; do

  data="al=1&next_from=PUlYVA8${page}&silent_loading=1"
  html=$(curl -s -A "${user_agent}" -X POST "${url}" -d "${data}" | iconv -f cp1251)
  link=($(echo "${html}" | grep -oP 'video-[^"]+"' | sed 's/video-/https:\/\/vkvideo.ru\/video-/g ; s/..$//'))
  title=$(echo "${html}" | grep -oP '\[\\"[^"]+"' | sed 's/^...// ; s/..$//')
  
  IFS=$'\n'
  counter=0
  
  for item in $(echo "${title}"); do

    echo -e "${item}\n${link[$counter]}\n"
    echo "#EXTINF:-1, $(echo ${item} | sed 's/,/\&#44;/g ; s/\&#33;/!/g; s/\&#63;/?/g')" >> playlist.m3u
    echo "${link[$counter]}" >> playlist.m3u
    ((counter+=1))
    
  done
  
done
echo -ne ${normal}

