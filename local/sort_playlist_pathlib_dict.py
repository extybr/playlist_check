#!/bin/env python3
# ./sort_playlist_pathlib_dict.py /path
# Сортировка плейлиста (по алфавиту), в переданном плейлисте только название и
# путь к файлу (без пустых строк и строк комментариев).
# Повторы удаляет.
import sys
from pathlib import Path


def get_dictionary(_filename: str) -> dict:
    dictionary = dict()
    txt = Path(_filename).read_text(encoding='utf-8').splitlines()
    name = ''
    for line in txt:
        if line.startswith('#EXTINF'):
            name = line
        else:
            address = line
            film = name.split(',')[-1]
            dictionary[film] = name, address
    return dictionary


def append_text(self, string: str) -> None:
    with self.open(mode="a", encoding="utf-8") as text:
        text.write(string)


def sorted_and_write(_file: str, _cwd: str) -> None:
    new_filename_path = f'{_cwd}/sorted-{_file}'
    new_dictionary = dict()
    _dictionary = get_dictionary(f'{_cwd}/{_file}')
    sort_dictionary = sorted(_dictionary)
    for key in sort_dictionary:
        new_dictionary[key] = _dictionary[key]
    content = Path(new_filename_path)
    content.write_text('#EXTM3U\n', encoding='utf-8')
    for value in new_dictionary.values():
        append_text(content, value[0] + '\n' + value[1] + '\n')


def main(cwd: str, ext: tuple) -> None:
    for file in Path(cwd).iterdir():
        if str(file.name).endswith(ext[0]) or str(file.name).endswith(ext[1]):
            print(f'найден файл: {file.name}')
            filename = str(file.name)
            sorted_and_write(filename, cwd)


extensions = 'm3u', 'm3u8'
if len(sys.argv) == 2:
    my_path = sys.argv[1]
    if not Path(my_path).exists():
        exit('путь не найден')
    main(my_path, extensions)
else:
    exit('не передан путь')
