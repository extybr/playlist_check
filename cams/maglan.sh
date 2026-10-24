#!/bin/bash
# $> ./maglan.sh
# Камеры Магадана / rec.maglan.ru

playlist='cams_Magadan.m3u'
URL="https://rec.maglan.ru"
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:158.0) Gecko/20100101 Firefox/158.0"

# получаем логин и пароль
login_pass=($(curl -s --location "$URL/demo" -H "User-Agent: $USER_AGENT" -H "Referer: $URL" \
              | grep '<input type="text" id="' | grep -oP 'value="\K[^"]+'))
login="${login_pass[0]}"
password="${login_pass[1]}"

# получаем куки
COOKIE=$(curl -s --location -D - "$URL/login.html" \
         -X POST \
         -H "User-Agent: $USER_AGENT" \
         -H 'Content-Type: application/x-www-form-urlencoded' \
         -H "Origin: $URL" \
         -H "Referer: $URL/demo" \
         --data-raw "yform_userForm=1&back=1&User%5BLogin%5D=${login}&User%5BPassword%5D=${password}&User%5BRemember%5D=0&submit=%D0%92%D0%BE%D0%B9%D1%82%D0%B8" | grep -oP 'PHPSESSIDFPST=[^;]+' | head -1 | sed 's/^.\{14\}//')

# проход по страницам и получение id всех камер      
nums() {
  for page in {1..6}; do
    curl -s "$URL/account/view.html?page=$page" \
      -H "User-Agent: $USER_AGENT" \
      -H "Cookie: translationMetrics=0; PHPSESSIDFPST=$COOKIE; html5=1; grid=7; cnum=5" \
      | grep -oP '"TranslationURLRequest":"\K[^"]+",' | grep -o '[0-9]\{3,4\}'
  done
}

# получение названий и url камер
for i in $(nums); do
  curl -s "$URL/map/video.html" \
    -X POST \
    -H "User-Agent: $USER_AGENT" \
    -H "Cookie: PHPSESSIDFPST=$COOKIE; html5=1; object=17; cnum=5; grid=1" \
    --data-raw "id=$i&random=false" | jq -r '"#EXTINF:-1," + .address,.url' >> $playlist  # rtsp ссылки
    # --data-raw "id=$i&random=false" | jq -r '"#EXTINF:-1," + .address,.url + "/playlist.m3u8"' >> $playlist  # hls ссылки
done

# правка строк с мусорными символами
sed -i 's/, / /g ; s/null//g' $playlist  # rtsp ссылки
# sed -i 's/, / /g ; s/null//g ; s/rtsp/hls/g' $playlist  # hls ссылки

echo "✅ Готово - $playlist"
