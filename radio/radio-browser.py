#!/usr/bin/python3

import requests

# url = "https://de1.api.radio-browser.info/json/stations/bycountry/us"
url = "https://de1.api.radio-browser.info/json/stations/topvote"
# url = "https://de1.api.radio-browser.info/json/stations"

playlist = 'radio_playlist.m3u'

request = requests.get(url)

if request.status_code == 200:
    js = request.json()
    with open(playlist, 'a', encoding='utf-8') as radio_playlist:
        radio_playlist.write('#EXTM3U\n')
        for line in js:
            name = line.get('name').strip()
            url = line.get('url')
            print(name)
            print(url)
            radio_playlist.write(f"#EXTINF:-1,{name}\n")
            radio_playlist.write(url + "\n")
