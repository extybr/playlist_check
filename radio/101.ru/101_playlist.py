#!/usr/bin/python3
import requests

dst = "https://101.ru/api/channel/getServers/"
file = '101_playlist.m3u'

with open(file, 'w', encoding='utf-8') as playlist:
    playlist.write("#EXTM3U\n")

with open(file, 'a', encoding='utf-8') as playlist:
    for page in range(1, 481):
        request = requests.get(f'{dst}{page}').json()
        if request.get("status", {}) == 0:
            continue
        result = request.get("result", {})
        if result:
            title = result[0].get("titleChannel", {})
            url = result[0].get("urlStream", {}).replace('http:', 'https:')
            if url.count('?'):
                url = url[:60][:url.index('?')]
            print(f'{title}\n{url}\n')
            playlist.write(f"#EXTINF:-1,{title}\n{url}\n")
