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


def sorted_and_write(_file: str, _cwd: Path) -> None:
    new_filename_path = _cwd / f'sorted--{_file}'
    new_dictionary = dict()
    _dictionary = get_dictionary(_file)
    new = sorted(_dictionary)
    for key in new:
        new_dictionary[key] = _dictionary[key]
    content = Path(new_filename_path)
    content.write_text('#EXTM3U\n', encoding='utf-8')
    for value in new_dictionary.values():
        append_text(content, value[0] + '\n' + value[1] + '\n')


def main(cwd: Path, ext: str) -> None:
    for file in Path(cwd).iterdir():
        if str(file.name).endswith(ext):
            print(f'найден файл: {file.name}')
            filename = str(file.name)
            sorted_and_write(filename, cwd)


extension = 'm3u8'
if len(sys.argv) == 2:
    my_path = sys.argv[1]
    if not Path(my_path).exists():
        exit('путь не найден')
    main(Path(my_path), extension)
else:
    exit('не передан путь')
