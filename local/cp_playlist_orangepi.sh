#!/bin/bash
# Копирование плейлиста на OrangePi/RaspberryPi с Libreelec (для gnome, сетевой пароль уже сохранен)
# Два варианта: для постоянного локального обновления, либо создание файла автозагрузки для автоматичекого обновления

source "$HOME/my_programs/.env.smb"  # получаю переменные ip, folder, udfolder, playlist, updplaylist, script

if ping -c 1 "$ip" &>/dev/null ; then  # если удаленный хост доступен
  cd "${GITHUB_DIRECTORY}/playlist_check/github" && ./${script}  # обновляю плейлист другим скриптом
  gio mount smb://"$ip"/"$folder"  # монтирую сетевую папку
  cp "${PLAYLIST_DIRECTORY}/${playlist}" /run/user/1000/gvfs/*="$folder"*  # копирую плейлист в сетевую папку
  echo "✅ Плейлист скопирован на $ip"  # сообщение об успешном копировании
else echo "❌ Хост $ip недоступен"  # иначе сообщение о недоступности
fi

# создание файла автозагрузки для запуска kodi и обновления плейлиста в libreelec
autoexec() {
  gio mount smb://"$ip"/"$udfolder" && cd /run/user/1000/gvfs/*="$udfolder"*  # монтирую сетевую папку и перехожу в нее
  echo "
  import xbmc
  import os
  xbmc.executebuiltin( \"PlayMedia(/storage/${folder}/TV-${playlist})\" )
  xbmc.executebuiltin( \"PlayerControl(repeat)\" )
  os.system(\"cd  /storage/${folder} && curl -O ${updplaylist}\")
  " > autoexec.py  # создаю файл, который запускается при загрузке системы
}

# autoexec  # для одного применения, после - система сама обновляет плейлист
