#!/usr/bin/python3
import requests

uid = 'uWDtYXqVMDM5JEywiksVg'
dst = f"https://www.fashiontv.com/_next/data/{uid}/index.json"
file = 'fashion_playlist.m3u'

request = requests.get(dst).json()

page_props = request.get('pageProps', {})
props = request.get('props', {})

celeb = page_props.get("videos", {})

first_video = page_props.get("homeContainer", {}).get("firstVideo", {})
title_stream = first_video.get("title", {})
first_video_url = first_video.get("streamURL", {})
url_stream = requests.get(first_video_url).text.split()[-1]

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
