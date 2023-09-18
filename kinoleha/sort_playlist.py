from pathlib import Path


def get_dictionary(_filename):
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


def sorted_and_write(_file):
    new_filename = f'sorted-{_file}'
    new_dictionary = dict()
    _dictionary = get_dictionary(_file)
    new = sorted(_dictionary)
    for key in new:
        new_dictionary[key] = _dictionary[key]
    with open(new_filename, 'a', encoding='utf-8') as text:
        for value in new_dictionary.values():
            text.write(value[0] + value[1])


def main():
    for file in Path().iterdir():
        if str(file).endswith('m3u'):
            print(file)
            filename = str(file)
            sorted_and_write(filename)
