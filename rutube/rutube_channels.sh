#!/bin/bash -
# $> ./rutube_channels.sh
# Ссылки rutube.ru

ch=$(curl -s 'https://rutube.ru/feeds/live/' | grep -o '{"id":"[a-z0-9]\{32\}","title":"[^"]*"')
echo "$ch" | sed 's/{"id":"/https:\/\/rutube.ru\/video\//g ; s/","title":"/ /g ; s/.$//g'

