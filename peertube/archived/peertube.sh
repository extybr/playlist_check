#!/bin/bash

######################
# example:           #
# $> ./peertube.sh   #
######################

blue='\033[36m'
yellow='\033[033m'
normal='\033[0m'

request=$(curl -s --location --max-time 3 'https://tube.reck.dk/feeds/videos.json?sort=-trending')
#request=$(curl -s --location --max-time 3 'https://tube.reck.dk/feeds/videos.json?videoChannelId=563')

for item in {0..19}; do
  echo -e "${blue}$(echo $request | jq -r ".items[${item}].title")${normal}"
  echo -e "${yellow}$(echo $request | jq -r ".items[${item}].url")${normal}"
  echo
done

