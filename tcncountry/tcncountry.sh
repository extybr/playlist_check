#!/bin/bash

# example:
# $> ./tcncountry.sh

green='\033[32m'
blue='\033[36m'
yellow='\033[1;33m'
violet="\033[35m"
normal='\033[0m'

# URL страницы канала
CHANNEL_URL="https://tcncountry.com/tnc-top-20-countdown/"

# Количество последних видео для получения
NUM_VIDEOS=5

echo "#EXTM3U
#EXTINF:-1,TCN Live
https://tcncountry.com/video/tcn-live/" > tcncountry.m3u

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

# Получение последних видео
output=$(get_latest_videos_from_html | head -n "${NUM_VIDEOS}")

# Запись последних видео
echo "$output" | while IFS='|' read -r title url; do
    echo "#EXTINF:-1,${title}" >> tcncountry.m3u
    echo "${url}" >> tcncountry.m3u
done

# Вывод самого последнего видео
printf "%s" "$output" | sed -n '1p' | while IFS='|' read -r title url; do 
	echo -e "${yellow}${title}${normal}"
	echo -e "${violet}${url}${normal}"
	echo
done

# Вывод последних видео, начиная с предпоследнего
echo "$output" | sed -n "2,+${NUM_VIDEOS}p" | while IFS='|' read -r title url; do 
	echo -e "${green}${title}${normal}"
	echo -e "${blue}${url}${normal}"
	echo
done

