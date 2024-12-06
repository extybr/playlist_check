import httpx
from multiprocessing import cpu_count
from multiprocessing.pool import ThreadPool
from typing import Dict

PL: Dict[int, str] = dict()


def check(_key: int) -> None:
    _value = PL[_key]
    print(_key)
    try:
        print(_value.strip())
        response: httpx.Response = httpx.get(_value.strip(),
                                             timeout=3.0, verify=False)
        print(response)
        if response.status_code == 200:
            with open('new.m3u', 'a', encoding='utf-8') as new:
                new.write(PL[_key - 1] + _value)
    except Exception as error:
        print(error)


if __name__ == '__main__':
    file = 'iptvlist.m3u'
    with open(file, 'r', encoding='utf-8') as playlist:
        for number, line in enumerate(playlist, 1):
            if line.strip():
                PL[number] = line
    # print(PL)
    with ThreadPool(processes=cpu_count()) as pool:
        for key, value in PL.items():
            if value.startswith('http') and '.m3u8' in value:
                pool.map(check, [key])
