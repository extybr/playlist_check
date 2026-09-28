#!/bin/bash
# только для вашего ip-адреса

tula1() {
  curl -s --location 'https://ok.ru/videoembed/977507065564' | \
  grep -oP '\&quot;https\K[^\&]+8?p\&q' | \
  sed '$d;s/:\/\//https:\/\//;s/8?p\&q/8/'
}

echo '#EXTM3U
#EXTINF:-1,1ый тульский
# https://ok.ru/videoembed/977507065564' > 1tula.m3u

tula1 >> 1tula.m3u

