from playwright.sync_api import sync_playwright
from urllib.parse import parse_qs
import sys


def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        captured = []
        page.on("request", lambda r: captured.append(r.post_data)
                if "get_anonym_token" in r.url and r.method == "POST"
                and r.post_data
                else None)
        page.goto("https://vkvideo.ru/tvchannels", wait_until="networkidle")
        browser.close()
    if not captured:
        print("Ошибка: get_anonym_token не перехвачен", file=sys.stderr)
        sys.exit(1)
    q = parse_qs(captured[0])
    print(f'client_id={q["client_id"][0]}')
    print(f'client_secret={q["client_secret"][0]}')
    print(f'app_id={q["app_id"][0]}')


if __name__ == "__main__":
    main()
