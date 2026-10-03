#!/bin/bash
# $> ./mcquack.sh
# Hostname: mcquack.net
# Provider: Internet Media Stream Ltd / OTT Club
# Location: The Netherlands / Ukraine (балансировщик нагрузки)

# с точным названием каналов, но есть пропуски по номерам каналов
curl -O 'http://stream.mcquack.net/stream.mcquack.net.m3u'

# без названий каналов, есть вероятность пропуска каналов
channel_scanning() {
for ch in {1..500}; do
  test=$(curl -s --location "http://stream.mcquack.net/${ch}/index.m3u8")
  if [[ $(echo "$test" | head -1) == "#EXTM3U" ]]; then
    url="http://stream.mcquack.net/${ch}/index.m3u8"
    echo -e "#EXTINF:-1,${ch}\n${url}" >> mcquack.m3u
    echo "${url}"
  fi
  sleep 0.5
done
}

# channel_scanning
