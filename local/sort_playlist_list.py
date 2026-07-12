#!/bin/env python3
# ./script.py /path/playlist.m3u
# Сортировка плейлиста (по алфавиту), в переданном плейлисте только название и
# путь к файлу (без пустых строк и строк комментариев).
# Повторы не удаляет.
import os
import sys


def get_list_playlist(playlist: str) -> list:
    with open(file=playlist, mode='r') as text:
        lines = text.readlines()
        letter = [i.split(',')[1][0] for i in lines if i.startswith('#EXTINF')]
        name = [i.strip() for i in lines if i.startswith('#EXTINF')]
        path = [i.strip() for i in lines if not i.startswith('#EXTINF')]
    return sorted(list(zip(letter, path, name)))


def write_new_playlist(playlist: str, sorted_playlist: list) -> None:
    with open(file=playlist, mode='a') as text:
        text.write('#EXTM3U\n')
        for _, path, name in sorted_playlist:
            np = f'{name}\n{path}'
            text.write(f'{np}\n')
            print(np)


if len(sys.argv) == 2:
    full_path = sys.argv[1]
    if not (os.path.exists(full_path) and os.path.isfile(full_path)):
        exit('путь не найден')
    new_full_path = f'{full_path}_sorted.m3u'
    sort_playlist = get_list_playlist(full_path)
    write_new_playlist(new_full_path, sort_playlist)
else:
    exit('не передан путь')
