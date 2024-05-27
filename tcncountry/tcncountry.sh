#!/bin/bash

# example:
# $> ./tcncountry.sh

red='\033[31m'
green='\033[32m'
blue='\033[36m'
normal='\033[0m'

# URL страницы канала
CHANNEL_URL="https://tcncountry.com/tnc-top-20-countdown/"

# Количество последних видео для получения
NUM_VIDEOS=5

echo -n "#EXTM3U
#EXTINF:-1,TCN Live
https://tcncountry.com/video/tcn-live/
" > tcncountry.m3u

# Функция загрузки HTML-страницы
get_html() {
    html=$(curl -s --location --max-time 3 "${CHANNEL_URL}")
}

# Функция для получения последних видео из HTML-страницы
get_latest_videos_from_html() {
    # Загружаем HTML страницу канала
    if get_html; then

    # Извлекаем названия и ссылки на видео
    titles=$(echo -e "${html}" | grep -oP '>Top 20 Countdown Week[^<]+' | sed 's/>//g')
    urls=$(echo -e "${html}" | grep -oP '<a href="https://tcncountry.com/video/top-20-countdown-week-[^"]+' | sed 's/<a href="//g' | uniq)

    # Соединяем названия и ссылки на видео
    paste -d'|' <(echo "${titles}") <(echo "${urls}")
    else get_latest_videos_from_html
    fi
}

# Получение и вывод последних видео
get_latest_videos_from_html | head -n "${NUM_VIDEOS}" | while IFS='|' read -r title url; do
    echo -e "${green}${title}${normal}"
    echo "#EXTINF:-1,${title}" >> tcncountry.m3u
    echo -e "${blue}${url}${normal}"
    echo "${url}" >> tcncountry.m3u
    echo
done


