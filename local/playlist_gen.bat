@echo off
mode con codepage select=1251 > nul
set name=music.m3u
echo Please wait...
set ind=0
:next
set /a ind+=1
set tmp=
for /f "delims=\ tokens=%ind%" %%a in ("%~dp0") do set tmp=%%a
if not "%tmp%"=="" goto next
set /a ind-=1
if exist %name% del %name%
for /f "delims=\ tokens=%ind%*" %%a in ('dir *.mp3 /b /s') do echo %%b >> %name%
mode con codepage select=866 > nul
if exist %name% start %name%