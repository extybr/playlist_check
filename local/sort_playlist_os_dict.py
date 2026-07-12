#!/bin/env python3
# ./sort_playlist_os_dict.py /path/playlist.m3u
# Сортировка плейлиста (по алфавиту), в переданном плейлисте только название и
# путь к файлу (без пустых строк и строк комментариев).
# Повторы удаляет.
import os
import sys


def get_dictionary(playlist_path: str) -> dict:
    dictionary = dict()
    with open(playlist_path, 'r', encoding='utf-8') as text:
        name = ''
        for line in text.readlines():
            if line.startswith('#EXTINF'):
                name = line
            else:
                path = line
                title = name.split(',')[-1]
                dictionary[title] = name, path
    return dictionary


def sorted_and_write(filename_path: str) -> None:
    new_filename_path = f'{filename_path}_sorted.m3u'
    new_dictionary = dict()
    _dictionary = get_dictionary(filename_path)
    sort_dictionary = sorted(_dictionary)
    for key in sort_dictionary:
        new_dictionary[key] = _dictionary[key]
    with open(new_filename_path, 'a', encoding='utf-8') as text:
        text.write('#EXTM3U\n')
        for value in new_dictionary.values():
            text.write(value[0] + value[1])


if len(sys.argv) == 2:
    full_path = sys.argv[1]
    if not (os.path.exists(full_path) and os.path.isfile(full_path)):
        exit('путь не найден')
    sorted_and_write(full_path)
else:
    exit('не передан путь')
