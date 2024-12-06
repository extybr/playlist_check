#!/bin/sh
#########################
# $> ./tcn_pl_make.sh   #
#########################

current_folder=$(pwd)
# cd ~/PycharmProjects/github/playlist_check/tcncountry
./watch.tcncountry.sh
if [ $(wc -c playlist.m3u | awk '{print $1}') -gt 500 ]
  then mv playlist.m3u tcn-live.m3u && \
  mv tcn-live.m3u "${PLAYLIST_DIRECTORY}" && \
  echo 'Playlist created and moved'
else rm playlist.m3u && echo '*** FAIL ***'
fi
cd "${current_folder}"

