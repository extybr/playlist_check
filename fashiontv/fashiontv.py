#!/usr/bin/python3
import requests
import re

url_tv = 'https://www.fashiontv.com'
file = 'fashion_playlist.m3u'

pattern = r"/_next/static/.{21}/_buildManifest.js"

text = requests.get(url_tv).text

uid = re.compile(pattern).findall(text)[0][14:-18]

dst = f"{url_tv}/_next/data/{uid}/index.json"

request = requests.get(dst).json()

page_props = request.get('pageProps', {})
props = request.get('props', {})

celeb = page_props.get("videos", {})

first_video = page_props.get("homeContainer", {}).get("firstVideo", {})
title_stream = first_video.get("title", {})
first_video_url = first_video.get("streamURL", {})
url_stream = first_video_url[:first_video_url.index('[')]

youtube_ftv = 'https://www.youtube.com/@ftv'

with open(file, 'w', encoding='utf-8') as playlist:
    playlist.write(f"#EXTM3U\n# fashiontv: {youtube_ftv}\n"
                   f"#EXTINF:-1,stream - {title_stream}\n{url_stream}\n")

content = page_props.get("homeContainer", {}).get("content", {})
with open(file, 'a', encoding='utf-8') as playlist:
    while content:
        videos = content.pop().get("videos", {})
        while videos:
            vid = videos.pop()
            title = vid.get("title", {})
            url = vid.get("streamURL", {})
            print(f'{title}\n{url}\n')
            playlist.write(f"#EXTINF:-1,{title}\n{url}\n")
