import asyncio
import aiofiles
from aiohttp import ClientSession, client_exceptions, ClientTimeout

PL = dict()
PLAYLIST = []
FILE = 'playlist.m3u'


async def fetch(session: ClientSession, url: str) -> None:
    try:
        async with session.get(url, timeout=ClientTimeout(total=3)) as response:
            if response.status == 200:
                PLAYLIST.append(url)
                # print(url, response.status)
    except (client_exceptions.ClientConnectorError, asyncio.TimeoutError):
        pass
    except Exception:
        pass


async def gen_dict() -> None:
    async with aiofiles.open(FILE, 'r', encoding='utf-8') as play_list:
        play = await play_list.readlines()
        for number, line in enumerate(play, 1):
            if line.strip():
                PL[number] = line


async def main() -> None:
    async with ClientSession() as session:
        urls = []
        task3 = asyncio.create_task(gen_dict())
        await asyncio.gather(task3)
        for _, value in PL.items():
            if value.startswith('http'):
                urls.append(value.strip())
        tasks = [asyncio.create_task(
            fetch(session=session, url=url)) for url in urls]
        result = await asyncio.gather(*tasks)
        for _ in result:
            print(_)


async def make_new_playlist() -> None:
    async with aiofiles.open(
            f'new_{FILE}', 'a', encoding='utf-8'
    ) as new_playlist:
        for i in PLAYLIST:
            await new_playlist.write(i + '\n')


if __name__ == '__main__':
    asyncio.run(main())
    asyncio.run(make_new_playlist())
