import asyncio
from aiofiles import open as aio_open
from aiohttp import ClientSession
from sort_playlist.sort_playlist import main as sort, Path


def read_file(file):
    base = set()
    with open(file, 'r', encoding='utf-8') as pl:
        for line in pl.readlines():
            if line.startswith('#EXTINF'):
                item_1 = line
            elif line.startswith('http'):
                item_2 = line
                base.add((item_1, item_2))
                continue
    return base


async def write_file(string):
    async with aio_open('new_file.m3u', 'a', encoding='utf-8') as file:
        await file.write(string)


async def fetch(session, url):
    result = url[0]
    try:
        async with session.get(url[1]) as response:
            result += str(response.real_url) + '\n'
    except Exception as er:
        print(er)
    else:
        if result:
            print(result)
            await write_file(result)


async def main(urls):
    async with ClientSession() as session:
        for url in urls:
            await fetch(session, url)


file_path = 'film.m3u'
links = read_file(file_path)
asyncio.run(main(links))
current_path = Path().cwd().absolute()
sort(current_path)
