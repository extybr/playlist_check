# Сортировка плейлиста (по алфавиту), в переданном плейлисте только название и
# путь к файлу (без пустых строк и строк комментариев).
# Повторы удаляет.
import os
import sys


def get_dictionary(_filename: str) -> dict:
    dictionary = dict()
    with open(_filename, 'r', encoding='utf-8') as text:
        txt = text.readlines()
        name = ''
        for line in txt:
            if line.startswith('#EXTINF'):
                name = line
            else:
                address = line
                film = name.split(',')[-1]
                dictionary[film] = name, address
    return dictionary


def sorted_and_write(_file: str, _cwd: str) -> None:
    new_filename_path =  f'{_cwd}/sorted-{_file}'
    new_dictionary = dict()
    _dictionary = get_dictionary(_file)
    new = sorted(_dictionary)
    for key in new:
        new_dictionary[key] = _dictionary[key]
    with open(new_filename_path, 'a', encoding='utf-8') as text:
        text.write('#EXTM3U\n')
        for value in new_dictionary.values():
            text.write(value[0] + value[1])


def main(cwd: str, ext: str) -> None:
    for _, _, files in os.walk(cwd):
        for file in files:
            if file.endswith(ext):
                print(f'найден файл: {file}')
                sorted_and_write(file, cwd)


extension = 'm3u8'
if len(sys.argv) == 2:
    my_path = sys.argv[1]
    if not (os.path.exists(my_path) and os.path.isdir(my_path)):
        exit('путь не найден')
    main(my_path, extension)
else:
    exit('не передан путь')
