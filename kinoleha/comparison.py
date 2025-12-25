# $> python comparison.py old_file.m3u new_file.m3u

import sys
from pathlib import Path

old_file = sys.argv[1]
new_file = sys.argv[2]
error = {old_file: 'первого файла', new_file: 'второго файла'}

for file in (old_file, new_file):
    if not Path(file).exists():
        print(f'\33[41m\33[1m Неверно указано имя {error[file]} файла '
              f'(или путь к нему)\33[0m')
else:
    with open(new_file, 'r', encoding='utf-8') as new_text, open(
              old_file, 'r', encoding='utf-8') as old_text:
        old = old_text.read()
        for line in new_text.readlines():
            if line not in old:
                print(line.strip())

    if sys.getsizeof(old_file) > sys.getsizeof(new_file):
        print('\33[41m\33[1mРазмер первого файла больше второго, возможно вы '
              'ошиблись с очередностью файлов.\33[0m')
