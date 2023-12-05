from json import loads
from httpx import get


def local_file():
    with open('radio_stream_list.json', 'r', encoding='utf-8') as js:
        with open('radio_stream_list.m3u', 'a', encoding='utf-8') as playlist:
            playlist.write('#EXTM3U\n')
            for line in js.readlines():
                radio = loads(line)
                ext = f"#EXTINF:-1,{radio['name']}\n{radio['url']}\n"
                playlist.writelines(ext)


def online_file():
    js = get('https://espradio.ru/stream_list.json').text
    pl = js.split('\r\n')
    with open('radio_stream_list.m3u', 'a', encoding='utf-8') as playlist:
        playlist.write('#EXTM3U\n')
        for item in pl:
            radio = loads(item)
            ext = f"#EXTINF:-1,{radio['name']}\n{radio['url']}\n"
            playlist.writelines(ext)


online_file()
# local_file()
