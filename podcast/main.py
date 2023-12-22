#############################
#                           #
#    #> python main.py      #
#                           #
#############################

from rss_links import get_links
from real_link import get_link_file
from download import complete_tasks
from pack import *


if __name__ == '__main__':
    file_download = False
    url_europe = 'https://redbasset.tech/_api/rest/podcast_rss/apple/7'
    url_radiot = 'https://feeds.feedburner.com/Radio-t'
    url_tricky_python = 'https://feed.podbean.com/learnpython/feed.xml'
    for link in (url_europe, url_radiot, url_tricky_python):
        get_links(link, file_download)
    if file_download:
        for url in urls:
            get_link_file(url)
        asyncio.run(complete_tasks())
