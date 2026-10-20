#!/bin/bash
# $> ./vktvchannels.sh
# Полная версия с cookie-файлом и вычислением анонимных client_id, client_secret, app_id
# Плейлист телеканалов с https://vkvideo.ru/tvchannels

USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36"
COOKIE_FILE="vkcookie.txt"
OUT_FILE="vktvchannels.m3u"
CREDS_CACHE="vktv_creds.txt"
CREDS_TTL=604800
API="5.444"

# 1. Динамически получаем client_id / client_secret / app_id (с кэшем)
if [ ! -f "$CREDS_CACHE" ] || [ $(( $(date +%s) - $(stat -c %Y "$CREDS_CACHE") )) -gt $CREDS_TTL ]; then
    mkdir -p "$(dirname "$CREDS_CACHE")"
    uv run get_vk_creds.py > "$CREDS_CACHE"
fi
eval "$(cat "$CREDS_CACHE")"

# 2. Прогреваем cookie-сессию
curl -s -o /dev/null --location 'https://vkvideo.ru/tvchannels' \
  -H "user-agent: $USER_AGENT" -c "$COOKIE_FILE" -b "$COOKIE_FILE"

# 3. Анонимный access_token
access_token=$(curl -s 'https://login.vk.ru/?act=get_anonym_token' \
  -X POST -H "user-agent: $USER_AGENT" \
  -c "$COOKIE_FILE" -b "$COOKIE_FILE" \
  --data-raw "client_secret=${client_secret}&client_id=${client_id}&scopes=audio_anonymous%2Cvideo_anonymous%2Cphotos_anonymous%2Cprofile_anonymous&isApiOauthAnonymEnabled=false&version=1&app_id=${app_id}" \
  | jq -r '.data.access_token')

# 4. Список каналов
curl -s "https://api.vkvideo.ru/method/catalog.getVideo?v=$API" \
  --compressed -X POST -H "user-agent: $USER_AGENT" \
  -c "$COOKIE_FILE" -b "$COOKIE_FILE" \
  --data-raw "url=https%3A%2F%2Fvkvideo.ru%2Ftvchannels&ref=&from_trackcode=&need_blocks=1&applied_toggles=%5B%5D&enabled_features=%5B%5D&access_token=${access_token}" \
  | jq -r '.response.videos[] | "#EXTINF:-1," + .title, .files.rtmp' \
  > "$OUT_FILE"

echo -e "client_id=${client_id}\nclient_secret=${client_secret}\napp_id=${app_id}\n"
echo "Готово: $OUT_FILE"
