import xml.dom.minidom
import urllib.request
from pack import urls


def get_links(url: str, download: bool = False) -> None:
    """Printing real links from podcast"""
    page = urllib.request.urlopen(url)
    doc = xml.dom.minidom.parse(page)
    enclosure = doc.getElementsByTagName("enclosure")
    for href in enclosure:
        result = href.getAttribute("url")
        print(result)
        if download:
            urls.append(result)
            break
