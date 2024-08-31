#!/bin/bash

blue="\033[36m"
yellow="\033[1;33m"
normal="\033[0m"

first=$(curl -s "https://watch.tcncountry.net" | grep -oP 'src="/assets/index[^>]+js' | sed 's/src="/https:\/\/watch.tcncountry.net/g')
second=$(curl -s "${first}" | grep -oP 'https://cdn.jwplayer.com/apps/configs/[^>]+",')
third=$(echo "${second}" | sed -n 1p | grep -oP 'https[^>]+son')
echo "${third}"
content=$(curl -s "${third}" | jq '.content')
for item in {0..20}; do 
  title=$(echo "${content}" | jq -r ".["${item}"].title")
  contentId=$(echo "${content}" | jq -r ".["${item}"].contentId")
  if [ "${title}" = 'null' ] && [ "${contentId}" = 'null' ]
    then break
  else 
    if [ "${title}" = 'null' ] || [ "${title}" = "" ] || [ "${contentId}" = 'null' ] || [ "${contentId}" = "" ]
    then continue
    fi
  echo -e "TITLE: ${blue}${title}${normal}, URL: ${yellow}https://watch.tcncountry.net/p/${contentId}${normal}"
  fi
done

