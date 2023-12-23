#################################################
# > python main.py http://example.com/file.mp3  #
#################################################

import os
import sys
import subprocess
import json
import httpx
from LxmlSoup import LxmlSoup

my_link = sys.argv[1] if len(sys.argv) > 1 else 0


def get_name_and_url() -> None:
    """Printing links"""
    for category in ('EXT5609', 'EXT1443'):
        html = httpx.get(f'https://redbasset.tech/podcast/{category}').text
        soup = LxmlSoup(html)

        links = soup.find_all('script', id='__NEXT_DATA__')
        js = json.loads(links[0].text())
        episodes = js.get("props", 0).get(
            "pageProps", 0).get("podcast", 0).get("episodes", 0)

        for link in episodes:
            print(link.get('name', 0))
            print(link.get('audioFileUrl', 0))


def curl_download(url: str) -> None:
    """Utility: curl. Download a file"""
    chcp = subprocess.getoutput('chcp').split(' ')[-1]
    result = subprocess.getoutput(f'curl -v {url}', encoding=chcp).split('\n')
    for line in result:
        if 'Location' in line:
            curl_download(line[11:])
    print(url)
    os.system(f'curl -O {url}')


if __name__ == "__main__":
    if my_link and my_link.startswith('http'):
        curl_download(my_link)
    else:
        get_name_and_url()
