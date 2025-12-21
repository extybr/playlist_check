#!/usr/bin/env python3
######################################
# $> ./scan_audio_files.py ~/Music   #
######################################
# Создание плейлиста аудиофайлов указанной директории

import sys
from pathlib import Path


def search(path: Path) -> None:
    exts = ['.mp3', '.flac', '.ape']
    for folder in sorted(path.iterdir()):
        if folder.is_dir():
            search(folder)
        for ext in exts:
            if str(folder).endswith(ext):
                with open(file='playlist.m3u', 
                          mode='a', encoding='utf-8') as playlist:
                    playlist.write(str(folder) + '\n')


if len(sys.argv) != 2:
    directory = Path(input('Укажите путь к папке: '))
else:
    directory = Path(sys.argv[1])

while not directory.exists() or not directory.is_dir():
    directory = Path(input('Укажите путь к папке: '))

with open(file='playlist.m3u', mode='w', encoding='utf-8') as playlist:
    playlist.write('#EXTM3U\n')

search(directory)
