#!/bin/bash -
# $> ./rutube_channels.sh
# Ссылки rutube.ru

user_agent='Mozilla/5.0 (X11; Linux x86_64; rv:149.0) Gecko/20100101 Firefox/149.0'

ch=$(curl -s -A "$user_agent" 'https://rutube.ru/feeds/live/' | \
     grep -o '{"id":"[a-z0-9]\{32\}","title":"[^"]*"')
echo "$ch" | sed 's/{"id":"/https:\/\/rutube.ru\/video\//g ; s/","title":"/ /g ; s/.$//g'

