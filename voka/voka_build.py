from pathlib import Path

d = dict()
new = dict()

c = 1
for file in Path().iterdir():
    if file.suffix == '.m3u':
        print(file)
        with open(file, 'r', encoding='utf-8') as playlist:
            for line in playlist:
                if line.startswith('#EXTINF') or line.startswith('http'):
                    d[c] = line
                    c += 1
        print(len(d))
for key, value in d.items():
    if value.startswith('https://cdn-cache01.voka.tv'):
        new[key-1] = d[key-1]
        new[key] = d[key]

new_set = set()
for i in new.values():
    if i.startswith('http'):
        new_set.add(i)
print(new_set)

# s = sorted([int(i.split('/')[-1][:-6]) for i in new_set])

with open('voka.m3u', 'a', encoding='utf-8') as playlist:
    for key, value in new.items():
        if value in new_set:
            playlist.write(new[key-1] + new[key])
            new_set.remove(value)
