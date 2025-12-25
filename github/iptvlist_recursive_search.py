# python iptvlist_recursive_search.py || uv run iptvlist_recursive_search.py
# Recursive playlist search
# Warning: The API request rate limit for the IP address may have been exceeded
# GitHub имеет лимит 60 запросов в час для неавторизованных запросов

import requests
import json
import os
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import List, Optional
from urllib.parse import urlparse

USER_REPO = ['Paradise-91/ParaTV', 'LeBazarDeBryan/XTVZ_', 'iptv-org/iptv']
DOWNLOAD_LIST = []
REQUEST_DELAY = 1  # Задержка между запросами к API в секундах
RATE_LIMIT_HIT = False


def response(url: str) -> Optional[str]:
    """HTTP запрос с обработкой ошибок и таймаутом"""
    global RATE_LIMIT_HIT
    headers = {'User-Agent': 'Mozilla/5.0'}
    try:
        time.sleep(REQUEST_DELAY)  # Задержка для соблюдения rate limits
        resp = requests.get(url, headers=headers, timeout=15)

        # Проверяем лимит запросов
        if resp.status_code == 403 and 'rate limit' in resp.text.lower():
            print(f"⚠️ Превышен лимит запросов для {url}")
            print("❌ Завершаю сканирование")
            RATE_LIMIT_HIT = True  # Устанавливаем флаг
            return None

        resp.raise_for_status()
        return resp.text
    except requests.RequestException as e:
        print(f"Ошибка запроса {url}: {e}")
        return None


def search_playlists(raw_data: List[dict]) -> None:
    """Рекурсивный поиск плейлистов в структуре GitHub"""
    global RATE_LIMIT_HIT

    # Проверка в начале функции флага превышения лимита запросов
    if RATE_LIMIT_HIT:
        return  # Просто выходим из рекурсии

    try:
        for item in raw_data:
            item_type = item.get('type')

            if item_type == 'file':
                # Проверяем, является ли файл плейлистом
                name = item.get('name', '')
                download_url = item.get('download_url')

                if download_url and name.endswith(('.m3u', '.m3u8')):
                    DOWNLOAD_LIST.append(download_url)
                    print(f"  [+] Найден плейлист: {name}")

            elif item_type == 'dir':
                # Получаем URL для содержимого папки
                api_url = item.get('url')  # Это правильный API URL для папки
                if api_url:
                    print(f"  [→] Захожу в папку: {item.get('name')}")
                    content = response(api_url)
                    if content:
                        search_playlists(json.loads(content))

    except Exception as e:
        print(f"Ошибка при обработке данных: {e}")


def download_parallel(urls: List[str],
                      folder: str = "playlists", workers: int = 3) -> None:
    """Многопоточное скачивание файлов"""
    os.makedirs(folder, exist_ok=True)

    def download_one(url: str) -> tuple[str, bool]:
        """Скачивание одного файла"""
        try:
            parsed = urlparse(url)
            filename = os.path.basename(parsed.path)

            # Если нет имени файла в URL, создаем свое
            if not filename or '.' not in filename:
                filename = f"playlist_{hash(url) % 10000:04d}.m3u"

            path = os.path.join(folder, filename)

            # Пропускаем уже скачанные
            if os.path.exists(path):
                return f"✓ Уже есть {filename}", True

            r = requests.get(url, stream=True, timeout=30)
            r.raise_for_status()

            with open(path, 'wb') as f:
                for chunk in r.iter_content(8192):
                    if chunk:
                        f.write(chunk)

            return f"✓ Скачан {filename} ({os.path.getsize(path)} bytes)", True
        except Exception as e:
            return f"✗ Ошибка {url}: {e}", False

    # Многопоточная обработка с прогрессом
    print(f"Скачиваю {len(urls)} файлов в папку '{folder}'...\n")

    with ThreadPoolExecutor(max_workers=workers) as executor:
        futures = {executor.submit(download_one, url): url for url in urls}

        success = 0
        for i, future in enumerate(as_completed(futures), 1):
            result, ok = future.result()
            print(f"[{i}/{len(urls)}] {result}")
            if ok:
                success += 1

    print(f"\nИтого: {success}/{len(urls)} файлов успешно скачано в '{folder}'")


def main() -> None:
    """Основная функция"""
    print("=" * 60)
    print("Сканер плейлистов из GitHub репозиториев")
    print("=" * 60)

    print(f"\nПроверяю {len(USER_REPO)} репозиториев...")
    print(f"Задержка между запросами: {REQUEST_DELAY} сек")

    for repo in USER_REPO:
        print(f"\n{'='*40}")
        print(f"Репозиторий: {repo}")
        print(f"{'='*40}")

        api_url = f"https://api.github.com/repos/{repo}/contents/"
        content = response(api_url)

        if content:
            try:
                data = json.loads(content)
                print(f"Найдено элементов в корне: {len(data)}")
                search_playlists(data)
            except json.JSONDecodeError:
                print(f"❌ Ошибка парсинга JSON для {repo}")
        else:
            print(f"❌ Не удалось получить данные из {repo}")

    print(f"\n{'='*60}")
    print(f"ИТОГО: Найдено {len(DOWNLOAD_LIST)} плейлистов")

    if DOWNLOAD_LIST:
        # Спрашиваем пользователя
        answer = input("\nНачать скачивание? (y/n): ").strip().lower()
        if answer == 'y':
            download_parallel(DOWNLOAD_LIST, workers=3)
        else:
            print("Скачивание отменено")
    else:
        print("❌ Плейлисты не найдены")


if __name__ == "__main__":
    main()
