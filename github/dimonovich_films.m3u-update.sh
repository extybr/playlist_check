#!/bin/bash
# $> ./dimonovich_films.m3u-update.sh
# Обновление плейлиста FILMS.m3u (https://github.com/Dimonovich/TV)

USER_REPO='Dimonovich/TV'
REPO_FILE='FILMS.m3u'
GIT_PATH='Dimonovich/FREE'
FILMS="${SAMSUNG_DIRECTORY}/Desktop/Radio/${REPO_FILE}"

if [ ! -f "$FILMS" ]; then
  FILMS="./${REPO_FILE}"
fi

check_date() {
  # получаем последний sha-коммита файла
  sha_commit=$(curl -s -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/${USER_REPO}/commits?path=${REPO_FILE}&per_page=1" | \
  jq -r '.[].sha')
  # получаем дату коммита
  gitfile_date=$(curl -s -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/${USER_REPO}/git/commits/${sha_commit}" | \
  jq -r '.author.date')
  # timestamp даты коммита
  git_ts=$(date -d "${gitfile_date}" +"%s")
  # дата изменения локального файла
  file_date=$(stat "${FILMS}" 2>/dev/null | grep 'Модифицирован' | awk '{print $2}')
  # если файла нет, то выходим из функции и создаем плейлист
  if ! [[ "$file_date" ]]; then return 0; fi
  # timestamp локального файла
  file_ts=$(date -d "${file_date}" +"%s")
  # сравниваем timestamp
  if [[ "${git_ts}" -gt "${file_ts}" ]]; then
    true
  else false
  fi
}

if check_date; then
  m3u=$(curl -s "https://raw.githubusercontent.com/${USER_REPO}/${GIT_PATH}/${REPO_FILE}")
  if [ "${#m3u}" -gt 100 ]; then
    echo "${m3u}" | \
    sed '1p; /#EXTINF:-1 group-title="Новинки кино/,$!d ; /^[[:space:]]*$/{N;/\n[[:space:]]*$/D}' > "${FILMS}"
    # sed -i "2i\#EXTINF:-1,         \n$HOME/Видео/Заглушка.mp4" "$films"
    echo -e "   >> \e[32mПлейлист обновлен\e[0m <<"
  fi
else echo -e "   >> \e[31mПлейлист не нуждается в обновлении\e[0m <<"
fi

