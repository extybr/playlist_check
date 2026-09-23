#!/bin/bash
# Копирование плейлиста на OrangePi/RaspberryPi с Libreelec (для gnome, сетевой пароль уже сохранен)
# Два варианта: для постоянного локального обновления, либо создание файла автозагрузки для автоматичекого обновления

source "$HOME/my_programs/.env.smb"  # получаю переменные ip, playlist, updplaylist, script, plretro, script_random

if ping -c 1 "$ip" &>/dev/null ; then  # если удаленный хост доступен
  cd "${GITHUB_DIRECTORY}/playlist_check/github" && ./${script}  # обновляю плейлист другим скриптом
  gio mount smb://"$ip"/videos  # монтирую сетевую папку
  cp "${PLAYLIST_DIRECTORY}/${playlist}" /run/user/1000/gvfs/*=videos*  # копирую плейлист в сетевую папку
  echo "✅ Плейлист скопирован на $ip"  # сообщение об успешном копировании
else echo "❌ Хост $ip недоступен"  # иначе сообщение о недоступности
fi

DEFAULT="
import xbmc
xbmc.executebuiltin( \"PlayMedia(/storage/videos/TV-${playlist})\" )
xbmc.executebuiltin( \"PlayerControl(repeat)\" )
"

UPDATE="
import xbmc
import os
import time

try:
    with open(\"/storage/.kodi/userdata/timestamp\", \"r\") as f:
        if float(time.time()) - float(f.read()) > 400000:
            os.system(\"cd  /storage/videos && curl -O ${updplaylist}\")
            os.system(\"/storage/.kodi/userdata/${script_random} /storage/videos/${plretro}\")
except Exception:
    pass
finally:
    xbmc.executebuiltin( \"PlayMedia(/storage/videos/TV-${playlist})\" )
    xbmc.executebuiltin( \"PlayerControl(repeat)\" )
"

# создание файла автозагрузки для запуска kodi и обновления плейлиста в libreelec
autoexec() {
  gio mount smb://"$ip"/userdata && cd /run/user/1000/gvfs/*=userdata*  # монтирую сетевую папку и перехожу в нее
  echo "$UPDATE" > autoexec.py  # создаю файл, который запускается при загрузке системы
}

# autoexec  # для одного применения, после - система сама обновляет плейлист

