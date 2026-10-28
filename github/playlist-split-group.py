#!/usr/bin/env python
# $> ./playlist-split-group.py
# $> ./playlist-split-group.py https://iptv-org.github.io/iptv/countries/ru.m3u
# $> ./playlist-split-group.py /path-to-local-file/playlist.m3u
# Разделение плейлиста и создание плейлиста по выбранной группе

import re
import sys
import os
import urllib.request

DEFAULT_PLAYLIST = ('https://raw.githubusercontent.com/Dimonovich/TV/refs/'
                    'heads/Dimonovich/FREE/FILMS.m3u')
GROUP_RE = re.compile(r'group-title="([^"]+)"')


def load_playlist(src):
    if src.startswith('http'):
        try:
            with urllib.request.urlopen(src, timeout=5) as r:
                if r.status != 200:
                    sys.exit(1)
                return r.read().decode('utf-8', errors='replace')
        except Exception:
            sys.exit(1)
    if os.path.exists(src):
        with open(src, encoding='utf-8') as f:
            return f.read()
    sys.exit(f'Не найден плейлист: {src}')


def parse_blocks(lines):
    blocks, cur = [], []
    for line in lines:
        line = line.strip()
        if not line:
            continue
        if line.startswith('#EXTINF'):
            if cur:
                blocks.append(cur)
            cur = [line]
        elif cur:
            cur.append(line)
    if cur:
        blocks.append(cur)
    return blocks


def block_group(block):
    m = GROUP_RE.search(block[0])
    return m.group(1) if m else None


def safe_filename(name):
    return re.sub(r'[\\/:*?"<>|\r\n]+', '_', name).strip() or 'playlist'


def write_playlist(path, blocks):
    if os.path.exists(path):
        os.rename(path, f'{os.path.splitext(path)[0]}_old.m3u')
    with open(path, 'w', encoding='utf-8') as f:
        for block in blocks:
            f.write('\n'.join(block) + '\n')


def main():
    src = sys.argv[1] if len(sys.argv) == 2 else DEFAULT_PLAYLIST
    if len(sys.argv) > 2:
        sys.exit(1)

    blocks = parse_blocks(load_playlist(src).splitlines())
    if not blocks:
        sys.exit('Плейлист пуст или не распознан')

    groups = sorted({g for b in blocks if (g := block_group(b))})
    for i, name in enumerate(groups, 1):
        print(f'{i}: {name}')

    choice = 0
    while not (1 <= choice <= len(groups)):
        try:
            choice = int(input(
                "\n\033[35mВыбрать цифру темы для создания плейлиста:\033[0m "))
        except ValueError:
            continue
        except KeyboardInterrupt:
            sys.exit(' \033[1;7;31mОТМЕНА\033[0m')

    select = groups[choice - 1]
    print(f'Выбрано: \033[36m{select}\033[0m')
    selected = [b for b in blocks if block_group(b) == select]
    path = f'{safe_filename(select)}.m3u'
    write_playlist(path, selected)
    print(f'Создан плейлист: \033[36m{path}\033[0m')


if __name__ == '__main__':
    main()
