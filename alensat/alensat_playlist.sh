#!/bin/bash
# $> ./alensat_playlist.sh --force-login music 500
# alensat.com | Скачивание и генерация плейлистов

source secret.txt  # содержит LOGIN и PASSWORD
PROXY="127.0.0.1:1080"
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:139.0) Gecko/20100101 Firefox/139.0"
URL="https://alensat.com"
LOGIN_URL="${URL}/ucp.php?mode=login"
COOKIE_FILE="cookie.txt"
LOG_FILE="curl.log"
CHOICE="$1"
PAGE="${2:-1}"
FORCE_LOGIN=0

# --- Проверка установленных программ ---
for cmd in curl grep awk smplayer; do
  command -v $cmd >/dev/null || { echo "$cmd не установлен, установка обязательна"; exit 1; }
done

# --- Затирка лог файла ---
true > "$LOG_FILE"

# --- Изменения при принудительном логине ---
if [[ "$CHOICE" == "--force-login" ]]; then
  FORCE_LOGIN=1
  CHOICE="$2"
  PAGE="${3:-1}"
fi

# 🔧 URL-кодирование в bash
urlencode() {
  local str="$1"
  local length="${#str}"
  local encoded=""
  local pos c o

  for (( pos = 0; pos < length; pos++ )); do
    c="${str:$pos:1}"
    case "$c" in
      [a-zA-Z0-9.~_-]) encoded+="$c" ;;
      *) printf -v o '%%%02X' "'$c"
         encoded+="$o" ;;
    esac
  done
  echo "$encoded"
}

# --- Получение куки ---
function get_cookie() {
  echo "=== Получаем страницу логина (чтобы вытащить form_token и creation_time и sid) ==="
  html=$(curl -s "$LOGIN_URL" \
    -x "$PROXY" \
    -A "$USER_AGENT" \
    -c "$COOKIE_FILE" \
    -b "$COOKIE_FILE" \
    --fail \
    --trace-ascii "$LOG_FILE")  || { echo "Ошибка получения страницы логина"; exit 1; }
    
  form_token=$(echo "$html" | grep -oP 'name="form_token"\s+value="\K[^"]+')
  creation_time=$(echo "$html" | grep -oP 'name="creation_time"\s+value="\K[^"]+')
  sid=$(echo "$html" | grep -oP 'name="sid"\s+value="\K[^"]+')

  echo "Token: $form_token"
  echo "Time: $creation_time"
  echo "SID: $sid"

  echo "=== Отправляем POST-запрос на логин ==="
  
  user=$(urlencode "${LOGIN}")
  password=$(urlencode "${PASSWORD}")

  curl "$LOGIN_URL" \
  -x "$PROXY" \
  -c "$COOKIE_FILE" -b "$COOKIE_FILE" \
  -A "$USER_AGENT" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-raw "username=$user&password=$password&autologin=on&redirect=.%2Findex.php%3F&creation_time=$creation_time&form_token=$form_token&sid=$sid&login=%D0%92%D1%85%D0%BE%D0%B4" \
  --fail --trace-ascii "$LOG_FILE" || { echo "Ошибка отправки логина"; exit 1; }

  # Проверяем успешность логина по cookie phpbb3_qhgig_u
  user_id=$(grep 'phpbb3_qhgig_u' "$COOKIE_FILE" | awk '{print $NF}')

  if [[ "$user_id" != "1" && -n "$user_id" ]]; then
    echo "✅ Успешный логин! ID пользователя: $user_id"
  else
    echo "❌ Логин не удался. Проверь логин/пароль или защиту Cloudflare." && exit 1
  fi
}

# --- Проверка куки ---
check_cookie() {
  response=$(curl -s -L -k -x "$PROXY" -A "$USER_AGENT" -b "$COOKIE_FILE" "$URL" \
             --fail --trace-ascii "$LOG_FILE")
  if echo "$response" | grep -q "ucp.php?mode=logout"; then
    echo "✅"
  elif echo "$response" | grep -q "ucp.php?mode=login"; then
    echo "❌"
  else
    echo "⚠️"
  fi
}

# --- Основной запрос для получения данных ---
request() {
  curl --fail -s -c "$COOKIE_FILE" -b "$COOKIE_FILE" --max-time 10 \
    --location --proxy "$PROXY" --compressed -A "$USER_AGENT" "$1" \
    -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
    -H 'Accept-Language: ru,en-US;q=0.7,en;q=0.3' -H 'Accept-Encoding: gzip, deflate, br' \
    -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' \
    --trace-ascii "$LOG_FILE" || { echo "Ошибка получения данных"; exit 1; }
}

# --- Создание плейлиста ---
make_playlist() {
  playlist="alensat_${CHOICE}.m3u"
  echo '﻿#EXTM3U' > "$playlist"

  declare -A targets=(
    [movies]="${URL}/viewtopic.php?f=86&t=287"
    [hd]="${URL}/viewtopic.php?f=86&t=6134"
    [music]="${URL}/viewtopic.php?f=86&t=2378"
    [sport]="${URL}/viewtopic.php?f=86&t=6132"
    [discovery]="${URL}/viewtopic.php?f=86&t=6133"
    [sup]="${URL}/viewtopic.php?f=2205&t=2373"
  )

  target="${targets[$CHOICE]}"
  if [[ -z "$target" ]]; then
    echo -e "Допустимые параметры: \033[00;35mmovies, hd, music, sport, discovery, sup\033[0m"
    exit
  fi

  last_page=$(request "$target" | grep -oP 'role="button"[^<]+' | grep -Eo '[0-9]+' | sort -n | tail -1)
  dev="&start=$(( (PAGE - 1) * 10 ))"

  if [[ "$target" = "${targets[sup]}" ]]; then
    request "${target}${dev}" | grep -oP 'http://[^"<> ]+\.(m3u8|m3u)\b' | uniq >> "$playlist"
  else
    request "${target}${dev}" | grep -oP '(#EXTINF|http://)[^<]+' | awk '
      /^#EXTINF/ {
        extinf = $0
        getline url
        if (url ~ /^http/) {
          pairs[++n] = extinf "\n" url
        }
      }
      END {
        for (i = 1; i <= n; i++) {
          print pairs[i]
        }
      }
    ' >> "$playlist"
  fi

  echo -e "\033[00;35mСгенерирован файл: \033[00;36m${playlist}"
  echo -e "\033[00;35mПоследняя страница: \033[00;36m${last_page}\033[0m"
  
  smplayer "${playlist}"
}

# === Авторизация, если требуется ===

cookie_time_expires=$(grep '^#' "$COOKIE_FILE" | tail -1 | awk '{print $5}')
now_time=$(date +%s)

if (( FORCE_LOGIN == 1 )); then
  echo "♻️  Принудительная авторизация (--force-login)"
  get_cookie
elif [[ -z "$cookie_time_expires" || "$cookie_time_expires" -lt "$now_time" || $(check_cookie) == "❌" ]]; then
  echo "🔐 Куки истекли или недействительны — авторизуемся..."
  get_cookie
fi

# === Запуск основного действия ===
try_login_and_run() {
  if [[ $(check_cookie) == "✅" ]]; then
    echo "✅ Куки валидны — пользователь авторизован."
    make_playlist
  else
    echo "🔁 Пытаемся авторизоваться..."
    get_cookie
    if [[ $(check_cookie) == "✅" ]]; then
      echo "✅ Куки валидны — пользователь авторизован."
      make_playlist
    else
      echo -e "⚠️ Невозможно подтвердить авторизацию. Проверь вручную: $URL"
    fi
  fi
}

try_login_and_run

