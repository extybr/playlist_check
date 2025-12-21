#!/bin/bash
# $> ./vkvideo_tvchannels_offline.sh
# save page as html only,
# change name > https___vkvideo.ru_tvchannels.txt

text='https___vkvideo.ru_tvchannels.txt'

echo -e '#EXTM3U' > playlist.m3u

cat "${text}" | iconv -f cp1251 | \
grep -oP 'alt=[^<]+' | head -n -2 | \
sed 's/alt="/#EXTINF:-1, /g ; s/" \/> //g' >> input.txt

cat "${text}" | iconv -f cp1251 | \
grep -oP 'title" href="/video-[^"]+"' | \
sed 's/>"//g ; s/.*source://' >> input.txt

paste -d '\n' <(head -n20 input.txt ) <(tail -n20 input.txt ) >> playlist.m3u

rm input.txt

