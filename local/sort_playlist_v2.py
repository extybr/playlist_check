#!/bin/env python3
# Сортировка плейлиста (по алфавиту), в переданном плейлисте только название и 
# путь к файлу (без пустых строк и строк комментариев).
# Повторы не удаляет.

def get_list_playlist(pl: str) -> list:
    with open(file=pl, mode='r') as text:
        lines = text.readlines()
        name = [i.strip() for i in lines if i.startswith('#EXTINF')]
        path = [i.strip() for i in lines if not i.startswith('#EXTINF')] 
    return list(zip(path, name))


def write_new_playlist(pl: str, sorted_playlist: list) -> None:
    with open(file=pl, mode='a') as text:
        text.write('#EXTM3U\n')
        for path, name in sorted_playlist:
            np = f'{name}\n{path}'
            text.write(f'{np}\n')
            print(np)


playlist = 'playlist.m3u8'
new_playlist = f'sorted_{playlist}'
sort_playlist = sorted(get_list_playlist(playlist))
write_new_playlist(new_playlist, sort_playlist)
