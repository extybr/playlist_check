####################################
# python playlist.py playlist.m3u  #
####################################

import sys
import subprocess

file = sys.argv[1]


def get_url() -> list:
    global file
    with open(file, 'r', encoding='utf-8') as playlist:
        text = playlist.readlines()
        for number, line in enumerate(text):
            if line.startswith('http'):
                cmd = f'./tv.sh {text.pop(number)}'
                text.insert(number, subprocess.getoutput(cmd) + '\n')
    return text


def write_playlist() -> None:
    global file
    with open(f'modified_{file}', 'a', encoding='utf-8') as playlist:
        text = get_url()
        for line in text:
            playlist.write(line)


write_playlist()
