import xml.dom.minidom
import urllib.request


def get_links(url):
    """Printing real links from podcast"""
    page = urllib.request.urlopen(url)
    doc = xml.dom.minidom.parse(page)
    expertise = doc.getElementsByTagName("enclosure")
    for skill in expertise:
        print(skill.getAttribute("url"))


if __name__ == '__main__':
    url_europe = 'https://redbasset.tech/_api/rest/podcast_rss/apple/7'
    url_radiot = 'https://feeds.feedburner.com/Radio-t'
    [get_links(link) for link in (url_europe, url_radiot)]
