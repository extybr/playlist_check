import httpx


def check(link: str) -> None:
    try:
        response: httpx.Response = httpx.get(link, timeout=2.0, verify=False)
        print(response)
        if response.status_code == 403:
            with open('voka.m3u', 'a', encoding='utf-8') as new:
                new.write(string + '\n')
    except Exception as error:
        print(error)


for i in range(1, 8000):
    string = f'https://cdn-cache01.voka.tv:443/live/{i}.m3u8'
    check(string)
