########################################################################
#  Example:                                                            #
# > python redbasset_podbean.py https://files.redbasset.tech/file.mp3  #
# > python redbasset_podbean.py https://mcdn.podbean.com/file.mp3      #
########################################################################

import os
import sys
import json
import httpx
from LxmlSoup import LxmlSoup
from typing import Iterable

my_link = sys.argv[1] if len(sys.argv) > 1 else 0


def get_name_and_url_podbean(soup: LxmlSoup) -> None:
    red, blue, default = '\033[31m', '\033[36m', '\033[0m'
    links = soup.find_all('script', type='application/ld+json')
    js = json.loads(links[0].text())

    for link in js[1:]:
        name = link.get('name', 0)
        url = link.get("associatedMedia", 0).get('contentUrl', 0)
        print(f"{red}{name}{default}\n{blue}{url}{default}")
        red = blue = default = ""


def get_name_and_url_redbasset(soup: LxmlSoup) -> None:
    red, blue, default = '\033[31m', '\033[36m', '\033[0m'
    links = soup.find_all('script', id='__NEXT_DATA__')
    js = json.loads(links[0].text())
    episodes = js.get("props", 0).get(
        "pageProps", 0).get("podcast", 0).get("episodes", 0)

    for link in episodes:
        name = link.get('name', 0)
        url = link.get('audioFileUrl', 0)
        print(f"{red}{name}{default}\n{blue}{url}{default}")
        red = blue = default = ""


def get_soup(idx: Iterable[str]) -> None:
    """Printing links"""
    for category in idx:

        categories = {'learnpython': 'https://learnpython.podbean.com/',
                      'Радио-Т-Podcast': 'https://www.podbean.com/'
                                         'podcast-detail/7f98v-57b7/'
                                         'Радио-Т-Podcast',
                      'EXT5609': 'https://redbasset.tech/podcast/',
                      'EXT1443': 'https://redbasset.tech/podcast/',
                      'EXT1343': 'https://redbasset.tech/podcast/'}

        url = (categories[category] if not categories[category].startswith(
            'https://redbasset.tech') else categories[category] + category)
        html = httpx.get(url).text
        soup = LxmlSoup(html)

        if category.startswith('EXT'):
            get_name_and_url_redbasset(soup=soup)
        else:
            get_name_and_url_podbean(soup=soup)


def curl_download(url: str) -> None:
    """Utility: curl. Download a file"""
    headers = httpx.get(url).headers
    if 'text/html' in headers['content-type']:
        return curl_download(headers['location'])
    print(url)
    if not url.endswith('.mp3'):
        url = url.split('.mp3')[0] + '.mp3'
    os.system(f'curl -O {url}')


if __name__ == "__main__":
    id_europe, id_radiot, id_python = 'EXT5609', 'EXT1443', 'EXT1343'
    redbasset = (id_europe, id_radiot, id_python)

    idx_python, idx_radiot = 'learnpython', 'Радио-Т-Podcast'
    podbean = (idx_python, idx_radiot)

    if my_link and my_link.startswith('http'):
        curl_download(my_link)
    else:
        get_soup(redbasset)
        print('\n*************\n')
        get_soup(podbean)
