#!/bin/bash
# $> ./vktvchannels.sh
# Облегченная версия с дефолтными анонимными client_id, client_secret, app_id, api
# Плейлист телеканалов с https://vkvideo.ru/tvchannels

USER_AGENT="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0"
client_secret="o557NLIkAErNhakXrQ7A"
client_id="52461373"
app_id=6287487
api="5.444"

access_token=$(curl -s 'https://login.vk.ru/?act=get_anonym_token' \
  -X POST \
  -H "$USER_AGENT" \
  --data-raw "client_secret=$client_secret&client_id=$client_id&scopes=audio_anonymous%2Cvideo_anonymous%2Cphotos_anonymous%2Cprofile_anonymous&isApiOauthAnonymEnabled=false&version=1&app_id=$app_id" | jq -r '.data.access_token')

curl -s "https://api.vkvideo.ru/method/catalog.getVideo?v=$api" \
  --compressed \
  -X POST \
  -H "$USER_AGENT" \
  --data-raw "url=https%3A%2F%2Fvkvideo.ru%2Ftvchannels&ref=&from_trackcode=&need_blocks=1&applied_toggles=%5B%5D&enabled_features=%5B%5D&access_token=$access_token" | jq -r '.response.videos.[] | "#EXTINF:-1," + .title,.files.rtmp' > vktvchannels.m3u

