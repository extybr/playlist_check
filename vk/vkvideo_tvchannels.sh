#!/bin/bash
# $> ./vkvideo_tvchannels.sh

blue="\e[36m"
normal="\e[0m"

user_agent="Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0"
url="https://vkvideo.ru/tvchannels"

echo -e '#EXTM3U' > playlist.m3u

list='GW0pkWF5UDwdZV3deXEENAltKZFhLTAcEFg AW0pkWF5UDwBZUnVSXUENB15KZFhLTAEEFg CW0pkWF5UDwZSUXdTUEEDDV5KZFhLTAAFFg'

echo -ne "${blue}"
for page in ${list[@]}; do

  data="al=1&next_from=PUlYVA8${page}&silent_loading=1"
  html=$(curl -s -A "${user_agent}" -X POST "${url}" -d "${data}" | iconv -f cp1251)
  link=($(echo "${html}" | grep -oP 'video-[^"]+"' | sed 's/video-/https:\/\/vkvideo.ru\/video-/g ; s/..$//'))
  title=$(echo "${html}" | grep -oP "class='VideoCard__ownerLink'>[^<]+<" | sed "s/class='VideoCard__ownerLink'>// ; s/.$//")
  
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

