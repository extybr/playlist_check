import httpx
from sort.sort_playlist import main as playlist_sort, Path


def online() -> None:
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


def local() -> None:
    film = 'film.m3u'
    mult = 'multfilm.m3u'
    group = (film, mult)
    for i in group:
        result = ''
        with open(i, 'r', encoding='utf-8') as pl:
            for line in pl:
                print(line)
                if line.startswith('http'):
                    result += httpx.get(
                        line.strip()).headers.get('location') + '\n'
                    continue
                result += line
        with open(f'new_{i}.m3u', 'a', encoding='utf-8') as playlist:
            for line in result:
                playlist.write(line)


# local()
online()
current_directory = Path().cwd().absolute()
playlist_sort(current_directory)
