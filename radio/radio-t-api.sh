#!/bin/bash
# $> ./radio-t-api.sh
# https://radio-t.com
# Для вывода тем и ссылки последнего выпуска через api
# https://radio-t.com/api-docs/ - основная документация по api
# https://radio-t.com/site-api/podcast/223 - информация о подкасте с заданным номером

blue='\e[36m'
yellow='\e[33m'
normal='\e[0m'

JSON=$(curl -s 'https://radio-t.com/site-api/last/1' | jq '.[0]')

get_json() {
  echo "$JSON" | jq -r ".$1"
}

echo -e "${blue}URL: ${yellow}$(get_json 'url')"
echo -e "${blue}Title: ${yellow}$(get_json 'title')"
echo -e "${blue}Date: ${yellow}$(get_json 'date')"
echo -e "${blue}Audio_url: ${yellow}$(get_json 'audio_url')${normal}"
echo -e "########## ${blue}Темы${normal} ##########"
echo "$JSON" | jq -r '.time_labels.[].topic'

