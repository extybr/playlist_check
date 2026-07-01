# Сортировка плейлиста (по алфавиту), в переданном плейлисте только название и
# путь к файлу (без пустых строк и строк комментариев).
# Повторы удаляет.
import sys
from pathlib import Path


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


def sorted_and_write(_file: str, _cwd: Path) -> None:
    new_filename_path = _cwd / f'sorted-{_file}'
    new_dictionary = dict()
    _dictionary = get_dictionary(_file)
    new = sorted(_dictionary)
    for key in new:
        new_dictionary[key] = _dictionary[key]
    with open(new_filename_path, 'a', encoding='utf-8') as text:
        text.write('#EXTM3U\n')
        for value in new_dictionary.values():
            text.write(value[0] + value[1])


def main(cwd: Path, ext: str) -> None:
    for file in Path(cwd).iterdir():
        if str(file.name).endswith(ext):
            print(f'найден файл: {file.name}')
            filename = str(file.name)
            sorted_and_write(filename, cwd)


extension = 'm3u8'
if len(sys.argv) == 2:
    my_path = sys.argv[1]
    main(Path(my_path), extension)
else:
    exit('не передан путь')
