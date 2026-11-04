#!/bin/bash
# $> ./rutube_last_video.sh https://rutube.ru/video/person/52298955/
# Последнее видео на канале rutube

USER_AGENT='Mozilla/5.0 (X11; Linux x86_64; rv:159.0) Gecko/20100101 Firefox/159.0'

request() {
  curl -s --compressed \
  -A "$USER_AGENT" "https://rutube.ru/api/video/person/${1}/?client=wdp&origin__type=rtb,rspa,vppl&page=1" \
  -H 'Accept: application/json, text/plain, */*' \
  | jq -r '.results.[0] | .feed_name,.title,.created_ts,.video_url + "\n"'
}

if [ "$#" -eq 1 ]; then
  person_id=$(echo "$1" | grep -o '[0-9]\{6,8\}')
  request "$person_id"
fi

