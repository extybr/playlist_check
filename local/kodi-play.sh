#!/usr/bin/env bash
# Запуск видео/потока в Kodi через JSON-RPC
# Использование:
#   ./kodi-play.sh -file "http://example.com/iptv/token/1001/index.m3u8"   # поток
#   ./kodi-play.sh -file "/storage/videos/video.mp4"                       # локальный файл или поток
#   ./kodi-play.sh -playlist "/storage/videos/FILMS.m3u"                   # m3u-плейлист с разворачиванием в очередь
#   ./kodi-play.sh -playlist MULTI 2                                       # m3u-плейлист с выбором позиции в плейлисте
#   ./kodi-play.sh -check                                                  # только показать, что играет
#   ./kodi-play.sh -reboot                                                 # перезагрузка устройства
#
# Из командной строки локально:
#   kodi-send --action='PlayMedia("http://example.com/index.m3u8")'
# Для остановки/паузы :
#   kodi-send --action='PlayerControl(Stop)' или PlayerControl(Play)
# Запуск по ssh:
#   ssh root@192.168.1.190 "kodi-send --action='PlayMedia(\"/storage/videos/FILMS.m3u\")'"

set -euo pipefail

# Настройки
source "$HOME/my_programs/.env.smb"  # импорт переменных
KODI_URL="${kodi_host}/jsonrpc"      # kodi_host="http://192.168.1.190:8080"
AUTH="${kodi_login_password}"        # kodi_login_password="XXXXXXXXXXXXXX=" в base64
# AUTH=$(printf '%s:%s' "my-login" "my-password" | base64 -w0)

# Вспомогательное
rpc() {
  # $1 — JSON-тело запроса
  curl -s "$KODI_URL" \
    --max-time 5 \
    -X POST \
    -H 'Content-Type: application/json' \
    -H "Authorization: Basic ${AUTH}" \
    --data-raw "$1"
}

# Проверяем доступен ли хост с kodi
rpc '{"jsonrpc":"2.0","method":"JSONRPC.Ping","id":"ping"}' \
  | jq -e '.result == "pong"' >/dev/null \
  || { echo -e "❌ Хост по адресу \e[31m${KODI_URL%:*}\e[0m недоступен" >&2; exit 3; }

# Справка, если число параметров неверное
if [[ $# -lt 1 ]] || [[ $# -gt 3 ]]; then
  echo -e "⚠️  \e[36mИспользование:\e[0m $0 [-file|-playlist] <URL|путь>" >&2
  echo "                   $0 [-check|-reboot]" >&2
  exit 1
fi

show_now_playing() {
  # Что реально играет: название + путь/URL
  rpc '[{"jsonrpc":"2.0","method":"XBMC.GetInfoLabels",
         "params":{"labels":["VideoPlayer.Title","Player.FilenameAndPath"]},
         "id":303}]' \
  | jq -r '.[0].result
           | "\u001b[36m▶ \(.["VideoPlayer.Title"] // "—")\u001b[0m\n  \(.["Player.FilenameAndPath"] // "—")"'
}

MODE="${1:-}"       # file = Player.Open с file, playlist = Clear→Add(directory)→Open
TARGET="${2:-}"     # переменная для воспроизведения в kodi, путь к файлу/плейлисту
POSITION="${3:-0}"  # позиция в плейлисте

case "$MODE" in
  -check)
    show_now_playing && exit 0
    ;;
  -reboot)
    rpc '{"jsonrpc":"2.0","method":"System.Reboot","params":[],"id":18}' && exit 0
    ;;
  -file)
    # Прямой запуск по пути/URL. Для потоков и одиночных файлов — самый простой путь.
    echo "→ Player.Open(file): $TARGET"         
    payload=$(jq -nc --arg f "$TARGET" '{jsonrpc:"2.0", method:"Player.Open",params:{item:{file:$f}}, id:"open"}')
    rpc "$payload" | jq -c .
    ;;
  -playlist)
    # Проверка, что выбор позиции является числом
    if [[ $# -eq 3 ]] && ! [[ "$POSITION" =~ ^[0-9]+$ ]]; then
      echo -e '⚠️  \e[31mПозиция в плейлисте должна быть числом\e[0m'
      exit 1
    fi
    
    # Проверка на сокращенный путь плейлиста
    if ! [[ "$2" =~ ^('http'|'/storage/') ]]; then
      TARGET="/storage/videos/$2.m3u"
    fi

    # Явная последовательность: Clear → Add(directory) → Open(position 0).
    # Нужна для m3u, чтобы Kodi развернул плейлист в отдельные элементы.
    echo "→ Playlist.Clear (video)"
    rpc '{"jsonrpc":"2.0","method":"Playlist.Clear",
          "params":{"playlistid":1},"id":"clear"}' >/dev/null

    echo "→ Playlist.Add(directory): $TARGET" 
    payload=$(jq -nc --arg d "$TARGET" '{jsonrpc:"2.0", method:"Playlist.Add",params:{playlistid:1, item:{directory:$d}}, id:"add"}')
    rpc "$payload" | jq -c .

    echo "→ Player.Open(position $POSITION)"
    payload=$(jq -nc --argjson p "$POSITION" '{jsonrpc:"2.0", method:"Player.Open",params:{item:{playlistid:1, position:$p}}, id:"open"}')
    rpc "$payload" | jq -c .
    ;;
  *)
    echo -e "⚠️  \e[36mНеизвестный режим: \e[31m$MODE\e[0m (ожидается -file|-playlist|-check|-reboot)" >&2
    exit 2
    ;;
esac

# Небольшая пауза, чтобы плеер успел подхватить поток, и отчёт
sleep 3
echo
show_now_playing
