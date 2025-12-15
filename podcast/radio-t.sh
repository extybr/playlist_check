#!/bin/bash
# $> ./radio-t.sh
# https://radio-t.com
# Для вывода тем и ссылки последнего выпуска

blue='\e[36m'
yellow='\e[33m'
normal='\e[0m'

html=$(curl -s 'http://feeds.rucast.net/radio-t')

urls=($(echo "${html}" | grep -oP 'url="http://cdn.radio-t.com[^>]+'))
url=$(echo "${urls[0]}" | sed 's/url="//g ; s/"\///g')
real_url=$(curl -s -I "${url}" | grep 'Location:' | sed 's/Location: //g')

themes=$(echo "${html}" | grep -oP '<itunes:subtitle>[^>]+')
IFS=$'\n'
counter=0
for theme in $(echo "${themes}"); do 
  ((counter+=1))
  if ((counter == 2)); then 
    IFS=$'.'
    for line in $(echo "${theme}"); do 
      echo -e "${yellow}${line}${normal}" | sed 's/<itunes:subtitle>//g ; s/<\/itunes:subtitle//g'
    done
  fi
done

echo -e "${blue}${real_url}${normal}"

