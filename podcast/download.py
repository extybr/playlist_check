import aiofiles
import tqdm
from pack import httpx, asyncio, new_urls


async def download_file(link_file: str, filename: str, size: int) -> None:
    """Downloading a file"""
    async with aiofiles.open(filename, 'wb') as file:
        async with httpx.AsyncClient() as client:
            async with client.stream("GET", link_file) as r:
                tqdm_params = {
                    'desc': link_file,
                    'total': size,
                    'miniters': 1,
                    'unit': 'it',
                    'unit_scale': True,
                    'unit_divisor': 1024
                }
                with tqdm.tqdm(**tqdm_params) as bar:
                    async for chunk in r.aiter_bytes(chunk_size=1):
                        bar.update()
                        await file.write(chunk)


async def complete_tasks() -> None:
    """Creating tasks for asynchronous file downloading"""
    tasks = []
    for url, name, size in new_urls:
        task = download_file(url, name, size)
        tasks.append(task)
    await asyncio.gather(*tasks)
