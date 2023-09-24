import httpx
from threading import Thread


def check(filename: str) -> None:
    out = ''
    with open(filename, 'r', encoding='utf-8') as playlist:
        count = 1
        for line in playlist.readlines():
            # print(count, line)
            out += line
            # if line.startswith('http'):
            if line.startswith('http') and '.m3u8' in line:
                try:
                    print(line.strip())
                    response: httpx.Response = httpx.get(line.strip(),
                                                         timeout=3.0, verify=False)
                    print(count, response)
                    if response.status_code == 200:
                        with open(f'new_{filename}', 'a', encoding='utf-8') as new:
                            new.write(out)
                except Exception as error:
                    print(error)
                out = ''
            count += 1


if __name__ == '__main__':
    file = 'iptvlist.m3u'
    threads = []
    thread = Thread(target=check, args=(file,))
    thread.start()
    threads.append(thread)
    for thread in threads:
        thread.join()
