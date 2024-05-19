############################################
# save (Ctrl + S) HTML page to text format #
# url = https://vk.com/video/lives/music   #
# playlist for smplayer                    #
############################################

red = '\033[31m'
blue = '\033[36m'
normal = '\033[0m'

with open('vk_lives_music_text.html', 'r', encoding='cp1251') as html:
    result = []
    sample = '<https://vk.com/video'
    text = html.readlines()
    for number, line in enumerate(text):
        if line.startswith(sample) and line[21:22] not in '/>':
            name = text[number - 1]
            link = line.strip()[1:-1]
            result.append((name, link))

with open('vk_lives_music.m3u', 'a', encoding='utf8') as playlist:
    playlist.write('#EXT3MU\n')
    for line in set(result):
        print(f'{red}{line[0]}{normal}{blue}{line[1]}{normal}')
        playlist.write(f'#EXTINF:-1,{line[0]}{line[1]}\n')
