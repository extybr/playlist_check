import asyncio
from aiofiles import open
from aiohttp import ClientSession, client_exceptions

PL = dict()
playlist = []


async def fetch(session, url):
    try:
        async with session.get(url, timeout=3) as response:
            if response.status == 200:
                global playlist
                playlist.append(url)
                # print(url, response.status)
                return url
    except (client_exceptions.ClientConnectorError, asyncio.TimeoutError):
        pass
    except Exception:
        pass


async def gen_dict():
    file = 'playlist.m3u'
    async with open(file, 'r', encoding='utf-8') as play_list:
        play = await play_list.readlines()
        for number, line in enumerate(play, 1):
            if line.strip():
                PL[number] = line


async def main():
    async with ClientSession() as session:
        urls = []
        task3 = asyncio.create_task(gen_dict())
        await asyncio.gather(task3)
        for key, value in PL.items():
            if value.startswith('http'):
                urls.append(value.strip())
        tasks = [asyncio.create_task(fetch(session, url)) for url in urls]
        result = await asyncio.gather(*tasks)
        for _ in result:
            print(_)


async def make_new_playlist():
    global playlist
    async with open('new_playlist.m3u', 'a', encoding='utf-8') as new_playlist:
        for i in playlist:
            await new_playlist.write(i + '\n')


if __name__ == '__main__':
    asyncio.run(main())
    asyncio.run(make_new_playlist())
