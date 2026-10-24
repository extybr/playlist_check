# Склейка плейлистов с удалением записи по дубликатам url
import sys
from pathlib import Path


def parse_playlist(filepath):
    entries = []
    extinf = None
    with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
        for line in f:
            line = line.rstrip('\n\r').lstrip('\ufeff')
            if not line.strip() or line.startswith('#'):
                if line.startswith('#EXTINF'):
                    extinf = line.strip()
                continue
            entries.append((extinf or '#EXTINF:-1,', line.strip()))
            extinf = None
    return entries


if len(sys.argv) < 2:
    print("Использование: python merge_m3u.py <папка> [выходной_файл]")
    sys.exit(1)

folder = Path(sys.argv[1])
outpath = sys.argv[2] if len(sys.argv) > 2 else 'merged_playlist.m3u'

if not folder.is_dir():
    sys.exit(f"Папка не найдена: {folder}")

seen = set()
result = []
total = 0
for path in sorted(folder.iterdir()):
    if path.suffix.lower() not in ('.m3u', '.m3u8'):
        continue
    print(f"Обработка: {path.name}", file=sys.stderr)
    for extinf, url in parse_playlist(path):
        total += 1
        if url in seen:
            continue
        seen.add(url)
        result.append((extinf, url))

print(f"Всего строк-записей: {total}")
print(f"Уникальных: {len(result)}")
print(f"Отброшено дублей: {total - len(result)}")

with open(outpath, 'w', encoding='utf-8') as f:
    f.write('#EXTM3U\n')
    for extinf, url in result:
        f.write(extinf + '\n' + url + '\n')

print(f"Готово: {len(result)} записей -> {outpath}")
