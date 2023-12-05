import httpx
from bs4 import BeautifulSoup
from sort.sort_playlist import main as playlist_sort, Path

HOST = 'https://kinoleha.net'


def get_html(_url: str) -> httpx.Response:
    # HEADERS = {'Host': HOST[8:], 'User-Agent': 'Safari'}
    result = httpx.get(_url)
    return result


def get_pages(genre: str) -> int:
    url = f'{HOST}/{genre}'
    html = get_html(url).text
    soup = BeautifulSoup(html, 'html.parser')
    items = soup.find_all('div', class_='pages')
    number = []
    for item in items:
        link = item.find_all('a')
        for i in link:
            pages = str(i.get('href')).split('/')[-1][3:]
            number.append(int(pages))
    if number:
        return max(number)
    return 1


def get_content(html: str, filename: str) -> None:
    filename = filename.replace('/', '-') + '.m3u'
    with open(filename, 'a', encoding='utf-8') as file:
        soup = BeautifulSoup(html, 'html.parser')
        items = soup.find_all('div', class_='centermid')
        for item in items:
            title = item.find_all('a')
            for k in title:
                link = str(k.get('href')).split('/')[-1]
                name = k.get('title')
                images = k.find_all('img')
                for image in images:
                    img = image.get('src')
                if name:
                    print(name, link)
                    file.writelines(f'#EXTINF:0 group-title="film" '
                                    f'tvg-logo="{HOST}{img}",{name}\n')
                    file.writelines(f'{HOST}/load/{link}?original\n')


def main(_categories: tuple) -> None:
    for category in _categories:
        pages = range(1, get_pages(category) + 1)
        for page in pages:
            url = f'{HOST}/{category}/str{page}'
            htm = get_html(url)
            get_content(htm.text, category)
    current_directory = Path().cwd().absolute()
    playlist_sort(current_directory)
