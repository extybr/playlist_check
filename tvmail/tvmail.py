import httpx

url = "https://tv.mail.ru/ajax/channel/list/"
request = httpx.get(url).json()
with open('tvmail.m3u', 'a', encoding='utf-8') as playlist:
    playlist.write("#EXTM3U\n")
    for ch in request["channels"]:
        if ch.get("url_online", {}):
            name = ch["name"]
            url_online = ch["url_online"]
            playlist.write(f"#EXTINF:-1,{name}\nhttps://tv.mail.ru{url_online}\n")
        
