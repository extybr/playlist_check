#!/bin/env python3
# ./sort_playlist_list.py /path/playlist.m3u      # по алфавиту
# ./sort_playlist_list.py /path/playlist.m3u num  # по цифрам: сезон, серия
# Сортировка плейлиста (опционально: по алфавиту или цифрам).
# Повторы не удаляет (удаляет - закомментированно).
import os
import sys


def get_list_playlist(playlist: str, n: int = 0) -> list:
    with open(file=playlist, mode='r') as text:
        lines = text.readlines()
        for line in lines.copy():
            if ((line.startswith('#') and not line.startswith('#EXTINF'))
                    or not line.strip()):
                lines.remove(line)
        letter = []
        if n:
            strings = [i.split(',')[1].strip()
                       for i in lines if i.startswith('#EXTINF')]
            for string in strings:
                chs = ''
                for ch in string:
                    if ch.isdigit():
                        chs += ch
                letter.append(int(chs))
        else:
            letter = [i.split(',')[1][0].lower()
                      for i in lines if i.startswith('#EXTINF')]
        name = [i.strip() for i in lines if i.startswith('#EXTINF')]
        path = [i.strip() for i in lines if not i.startswith('#EXTINF')]
    # return sorted(list(set(list(zip(letter, path, name)))))  # удалит повторы
    return sorted(list(zip(letter, path, name)))


def write_new_playlist(playlist: str, sorted_playlist: list) -> None:
    with open(file=playlist, mode='a') as text:
        text.write('#EXTM3U\n')
        for _, path, name in sorted_playlist:
            np = f'{name}\n{path}'
            text.write(f'{np}\n')
            print(np)


if len(sys.argv) == 2 or len(sys.argv) == 3:
    full_path = sys.argv[1]
    if not (os.path.exists(full_path) and os.path.isfile(full_path)):
        exit('путь не найден')
    new_full_path = f'{full_path}_sorted.m3u'
    sort_playlist = (get_list_playlist(full_path, 1) if len(sys.argv) == 3
                     else get_list_playlist(full_path))
    write_new_playlist(new_full_path, sort_playlist)
else:
    exit('не передан путь')
