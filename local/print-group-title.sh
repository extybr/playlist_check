#!/bin/bash
# $> ./print-group-title.sh https://example.com/playlist.m3u
# $> ./print-group-title.sh /path-to-file/playlist.m3u
# Печать group-title с плейлиста в консоль

curl_playlist() {
  curl -s "$1" | grep -oP 'group-title="[^"]+' | sort -u | sed 's/^.\{13\}//g' | nl
}

py_subprocess_playlist() {
  python -c "import subprocess,re; pl = subprocess.getoutput('curl -s $1'); title = set(re.findall(r'group-title=\"([^\"]+)\"', pl)); [print(i) for i in title]" | nl
}

py_requests_playlist() {
  python -c "import requests,re; pl = requests.get('$1').text; title = set(re.findall(r'group-title=\"([^\"]+)\"', pl)); [print(i) for i in title]" | nl
}

cat_playlist() {
  cat "$1" | grep -oP 'group-title="[^"]+' | sort -u | sed 's/^.\{13\}//g' | nl
}

if [ "$#" -gt 1 ]; then
  exit 1
elif [ "$#" -eq 1 ]; then
  if [[ "$1" =~ ^(http) ]]; then
    #py_subprocess_playlist "$1"
    py_requests_playlist "$1"
  elif [ -f "$1" ]; then
    cat_playlist "$1"
  else exit 1
  fi
else curl_playlist "https://raw.githubusercontent.com/Dimonovich/TV/refs/heads/Dimonovich/FREE/FILMS.m3u"
fi

