import requests
from threading import Thread


def func(filename):
    out = ''
    with open(filename, 'r', encoding='utf-8') as ip:
        k = 1
        for i in ip.readlines():
            # print(k, i)
            out += i
            # if i.startswith('http'):
            if i.startswith('http') and '.m3u' in i:
                try:
                    print(i.strip())
                    r: requests.Response = requests.get(i.strip(), timeout=3.0)
                    print(k, r)
                    if r.status_code == 200:
                        with open(f'new_{filename}', 'a', encoding='utf-8') as new:
                            new.write(out)
                except Exception as er:
                    print(er)
                out = ''
            k += 1


if __name__ == '__main__':
    file = 'iptvchannels.m3u'
    threads = []
    thread = Thread(target=func, args=(file,))
    thread.start()
    threads.append(thread)
    for thread in threads:
        thread.join()

