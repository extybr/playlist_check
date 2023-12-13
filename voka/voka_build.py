from pathlib import Path

current = dict()
new = dict()

counter = 1
for file in Path().iterdir():
    if file.suffix == '.m3u':
        print(file)
        with open(file, 'r', encoding='utf-8') as playlist:
            for line in playlist:
                if line.startswith('#EXTINF') or line.startswith('http'):
                    current[counter] = line
                    counter += 1
        print(len(current))
for key, value in current.items():
    if value.startswith('https://cdn-cache01.voka.tv'):
        new[key-1] = current[key-1]
        new[key] = current[key]

new_set = set()
for line in new.values():
    if line.startswith('http'):
        new_set.add(line)
print(new_set)

with open('voka.m3u', 'a', encoding='utf-8') as playlist:
    for key, value in new.items():
        if value in new_set:
            playlist.write(new[key-1] + new[key])
            new_set.remove(value)
