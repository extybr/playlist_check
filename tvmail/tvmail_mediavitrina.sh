#!/bin/bash
# $> ./tvmail_mediavitrina.sh

PLAYLIST='tvmail_mediavitrina.m3u'

request() {
  echo "#EXTINF:-1,$1" >> $PLAYLIST
  curl -s "https://media.mediavitrina.ru/balancer/v3/$1/streams.json?application_id=&player_referer_hostname=tv.mail.ru&config_checksum_sha256=undefined&egress_version_id=17247457&" \
    --compressed \
    -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:158.0) Gecko/20100101 Firefox/158.0' \
    -H 'Accept-Language: ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7' \
    -H 'Referer: https://player.mediavitrina.ru/' | jq -r '.hls.[]' | head -1 >> $PLAYLIST
}  
  
chs=(
russia1/russia1_7
default_2026/tvc 
kultura/russiak
nmg/rentv7
tnt/gpm_tnt7
dom/domashniy_msk7
russia24/russia24
gpm_friday/gpm_friday7
tv3/gpm_tv37
)

for ch in "${chs[@]}"; do
  request $ch
done

