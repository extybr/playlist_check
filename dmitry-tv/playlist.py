####################################
# python playlist.py playlist.m3u  #
####################################

import sys
import subprocess

FILE = sys.argv[1]


def get_url() -> list:
    with open(FILE, 'r', encoding='utf-8') as playlist:
        return playlist.readlines()
    

def write_playlist() -> None:
    text: list = get_url()
    with open(f'modified_{FILE}', 'a', encoding='utf-8') as playlist:
        for number, line in enumerate(text):
            if line.startswith('http'):
                cmd = f'./tv.sh {line.strip()}'
                link = subprocess.getoutput(cmd)
                if link.startswith('http'):
                     playlist.write(f'{text[number - 1]}{link}\n')
                     print(link)


write_playlist()
