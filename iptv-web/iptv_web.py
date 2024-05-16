import httpx
import re
from bs4 import BeautifulSoup

URL = 'https://iptv-web.app/'


def get_html(_url: str) -> httpx.Response:
    result = httpx.get(_url, follow_redirects=True)
    return result


def get_list_link(area: str) -> set:

    result = []
    html = get_html(URL + area).text
    soup = BeautifulSoup(html, 'html.parser')
    main = soup.find_all('main')
    links = main[0].find_all('a')

    for link in links:
        href = link.get('href')
        if href:
            result.append(href[1:])

    return set(result)


def get_playlist(area: str) -> None:

    urls = get_list_link(area)
    file = f'iptv_web_{area}.m3u'

    RED = '\033[31m'
    BLUE = '\033[36m'
    DEFAULT = '\033[0m'

    pattern_1 = r'<title>.+</title>'
    pattern_2 = r'<video id="video" src="http.+.m3u8"'
    pattern_3 = (r'<a target="_blank" rel="noopener '
                  'noreferrer" href="http.+.m3u8"')

    with open(file, 'w', encoding='utf-8') as playlist:
        playlist.write('#EXTM3U\n')

    for url in urls:

        name, link = '', ''

        code_page = httpx.get(URL + url).text
        
        sample_1 = re.compile(pattern_1)
        title = sample_1.search(code_page)
        if title:
            name = code_page[title.start() + 7:title.end() - 8]

        sample_2 = re.compile(pattern_2)
        src_link = sample_2.search(code_page)
        if src_link:
            link = code_page[src_link.start() + 23:src_link.end() - 1]
        else:
            sample_3 = re.compile(pattern_3)
            src_link = sample_3.search(code_page)
            if src_link:
                link = code_page[src_link.start() + 51:src_link.end() - 1]

        if name and link:
            print(f'{RED}{name}{DEFAULT}: {BLUE}{link}{DEFAULT}')
            with open(file, 'a', encoding='utf-8') as playlist:
                playlist.write(f'#EXTINF:-1,{name}\n{link}\n')


if __name__ == "__main__":
    areas = ['RU']
    for country in areas:
        get_playlist(country)
