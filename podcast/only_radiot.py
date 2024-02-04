from pack import httpx

URL = 'https://archive.rucast.net/radio-t/media/'


def get_max_number():
    result = httpx.get(URL).text.split('\r\n')
    numbers = []
    for line in result:
        if line.startswith('<a href="rt_podcast'):
            number = line[19:].split('.mp3">rt_podcast')[0]
            if number.isdigit():
                numbers.append(int(number))
    return max(numbers)


link = URL + 'rt_podcast' + str(get_max_number()) + '.mp3'
print(link)
