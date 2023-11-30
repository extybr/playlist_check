from pathlib import Path


def get_dictionary(_filename: str) -> dict:
    dictionary = dict()
    with open(_filename, 'r', encoding='utf-8') as text:
        txt = text.readlines()
        # print(txt)
        for line in txt:
            if not line.startswith('http'):
                name = line
            else:
                address = line
                film = name.split('",')[-1]
                # print(film)
                dictionary[film] = name, address
    return dictionary


def sorted_and_write(_file: str, _cwd: str) -> None:
    new_filename_path = Path(_cwd) / f'sorted-{_file}'
    new_dictionary = dict()
    _dictionary = get_dictionary(_file)
    new = sorted(_dictionary)
    for key in new:
        new_dictionary[key] = _dictionary[key]
    with open(new_filename_path, 'a', encoding='utf-8') as text:
        text.write('#EXTM3U\n')
        for value in new_dictionary.values():
            text.write(value[0] + value[1])


def main(cwd) -> None:
    for file in Path(cwd).iterdir():
        if str(file.name).endswith('m3u'):
            print(file.name)
            filename = str(file.name)
            sorted_and_write(filename, cwd)
