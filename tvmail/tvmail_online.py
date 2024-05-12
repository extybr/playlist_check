import httpx
from bs4 import BeautifulSoup

URL = "https://tv.mail.ru/online/"


def get_html(_url: str) -> httpx.Response:
    result = httpx.get(_url)
    return result


def get_list_link() -> list:
    html = get_html(URL).text
    soup = BeautifulSoup(html, 'html.parser')
    _class = 'link link_underline p-live-list__link js-live_link'
    return soup.find_all('a', class_=_class)


def write_playlist() -> None:
    items = get_list_link()
    with open('tvmail.m3u', 'a', encoding='utf-8') as playlist:
        playlist.write("#EXTM3U\n")
        for item in items:
            name = str(item.get('data-channel-name'))
            link = str(item.get('href'))
            playlist.write(f"#EXTINF:-1,{name}\nhttps://tv.mail.ru"
                           f"{link}\n")


    
if __name__ == "__main__":
    write_playlist()
