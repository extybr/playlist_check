#!/bin/sh

get_link() {
request=$(curl -s "${url}" 2> /dev/null | grep 'vgtrk' 2> /dev/null)
if ! [[ $request ]]
then request=$(curl -s -I --location "${url}" | grep 'vgtrk' | grep -v 'iframe' | sed 's/Location: //g')
fi
echo $request
}

url=$1
get_link $url

