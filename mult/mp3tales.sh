#!/bin/bash
# $> ./mp3tales.sh
# Аудиосказки для детей, аудиокниги и радиопостановки
# Ресурс: https://mp3tales.info

curl -o mp3tales.m3u 'https://mp3tales.info/playlist/?id=13&action=m3u8'
