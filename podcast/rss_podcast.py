import xml.dom.minidom
import urllib.request


def get_links(url: str, download: bool = False) -> None:
    """Printing real links from podcast"""
    page = urllib.request.urlopen(url)
    doc = xml.dom.minidom.parse(page)
    enclosure = doc.getElementsByTagName("enclosure")
    for href in enclosure:
        result = href.getAttribute("url")
        print(result)
        if download:
            download_file(result)
            break


def download_file(link_file: str) -> None:
    """Downloading a file"""
    filename = "{0}.{1}".format(
        link_file.rsplit('.', 2)[1][-10:], link_file.rsplit('.', 1)[1])
    urllib.request.urlretrieve(link_file, filename)


if __name__ == '__main__':
    file_download = False
    url_europe = 'https://redbasset.tech/_api/rest/podcast_rss/apple/7'
    url_tricky_python = 'https://feed.podbean.com/learnpython/feed.xml'
    url_radiot = 'https://feeds.feedburner.com/Radio-t'
    for link in (url_europe, url_tricky_python, url_radiot):
        get_links(link, file_download)
