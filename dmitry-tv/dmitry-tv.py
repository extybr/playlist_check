import httpx
from sort_playlist import main as sort

film = 'http://dmi3y-tv.ru/iptv/film.m3u'
mult = 'http://dmi3y-tv.ru/iptv/multfilm.m3u'
group = (film, mult)

for i in group:
    category = i.split('/')[-1][:-4]
    request = httpx.get(i).iter_lines()

    with open(f'{category}.m3u', 'a', encoding='utf-8') as playlist:
        for line in request:
            if line.startswith('http'):
                result = httpx.get(line).iter_lines()
                for real_link in result:
                    if real_link.startswith('http'):
                        playlist.writelines(real_link + '\n')
                        print(real_link)
                continue
            playlist.writelines(line + '\n')
            print(line)

sort()
