# $> python playlist.py playlist.m3u
# Модифицирует ссылки

import sys
import subprocess

if len(sys.argv) != 2:
    exit(0)
FILE = sys.argv[1]


def get_url() -> list:
    with open(FILE, 'r', encoding='utf-8') as playlist:
        return playlist.readlines()


def write_playlist() -> None:
    text: list = get_url()
    ignore = 'http://player.smotrim.ru/iframe/stream/live_id'
    subprocess.run(f'echo "{text.pop(0).strip()}" > modified_{FILE}',
                   shell=True)
    with open(f'modified_{FILE}', 'a', encoding='utf-8') as playlist:
        for number, line in enumerate(text):
            if line.startswith(ignore):
                playlist.write(f'{text[number - 1]}{line}')
                print(line, end='')
            elif line.startswith('http'):
                cmd = f'./tv.sh {line.strip()}'
                link = subprocess.getoutput(cmd)
                if link.startswith('http'):
                    playlist.write(f'{text[number - 1]}{link}\n')
                    print(link)


write_playlist()
