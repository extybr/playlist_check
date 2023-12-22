from typing import Callable
from pack import *


def get_link_file(link_file: str) -> Callable or None:
    """Create a list with a link, file name and file size"""
    filename = "{0}.{1}".format(
        link_file.rsplit('.', 2)[1][-10:], link_file.rsplit('.', 1)[1])
    if not filename.endswith('.mp3'):
        filename = "{0}.mp3".format(filename.rsplit('.mp3', 1)[0][-10:])
    with httpx.Client() as client:
        with client.stream("GET", link_file) as r:
            headers = r.headers
            size = int(headers.get('content-length', 0))
            if 'text' in headers.get('content-type', 0):
                return get_link_file(str(headers.get('location', 0)))
            new_urls.append((link_file, filename, size))
