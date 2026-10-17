#!/usr/bin/env python
# Разделение плейлиста FILMS.m3u после отработки
# скрипта dimonovich_films.m3u-update.sh

import subprocess
import re
# import requests

playlist = ('https://raw.githubusercontent.com/Dimonovich/TV/refs/heads/'
            'Dimonovich/FREE/FILMS.m3u')

output = subprocess.getoutput(f'curl -s {playlist}')
# output = requests.get(playlist).text

strings = output.split('\n')

titles = set(re.compile(r'group-title=\"[А-Яа-я_0-9 A-Za-z]+\"').findall(
    output))
group_titles = []

for title in titles:
    group_titles.append(title[13:-1])

for string in strings:
    if string.startswith('#EXTVLCOPT'):
        strings.remove(string)

for group_title in group_titles:
    with open(file=f'{group_title}.m3u', mode='a') as ploc:
        for index, string in enumerate(strings):
            if group_title in string:
                ploc.write(f'{strings[index]}\n{strings[index+1]}\n')
