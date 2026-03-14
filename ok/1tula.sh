#!/bin/bash
# только для вашего ip-адреса

tula() {
  curl -s --location 'https://ok.ru/videoembed/977507065564' | \
  grep -oP 'quot;\K[^\\]+8?p\\' | \
  sed '1d;$d;s/video.m3u8?p\\/485900290780_fullhd\/index.m3u8/'
}

echo '#EXTM3U
#EXTINF:-1,1ый тульский
# https://ok.ru/videoembed/977507065564' > 1tula.m3u

tula >> 1tula.m3u

