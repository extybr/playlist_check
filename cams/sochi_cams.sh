#!/bin/bash
# $> ./sochi_cams.sh
# Веб-камеры Сочи / интернет-провайдер Твонтел Юг

USER_AGENT='User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:158.0) Gecko/20100101 Firefox/158.0'
playlist='sochi_cams.m3u'

cams=$(curl -s --location -A "$USER_AGENT" "https://www.tvintel.info/web-camera/" \
       | grep -o '/web-camera/[0-9]\{3,4\}/')

echo "#EXTM3U" > $playlist
for cam in $cams; do
  request=$(curl -s --location -A "$USER_AGENT" "https://www.tvintel.info$cam")
  name=$(echo $request | grep -oP 'src="https://fl.tvintel.info:8443/\K[^/]+')
  alt=$(echo $request | grep -oP '<h1 class="camd__ttl">\K[^<]+')
  echo -e "#EXTINF:-1,$alt\nhttps://fl.tvintel.info:8443/$name/tracks-v1/index.fmp4.m3u8" >> $playlist
  # suf=(/tracks-v1/index.fmp4.m3u8, /tracks-v1a1/mono.m3u8, /index.m3u8)
done

