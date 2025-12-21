#!/bin/bash
# $> ./last-podcast.sh
# Последний подкаст

url='https://archive.rucast.net/radio-t/media/'
r=$(curl -s "$url" | tail +5 | head -n -2)

echo "$r" | awk '{
    # Извлекаем имя файла из href
    filename = $2
    gsub(/^href="/, "", filename)
    gsub(/">.*$/, "", filename)
    
    cmd = "date -d \"" $3 "\" +%s 2>/dev/null"
    cmd | getline timestamp
    close(cmd)
    print timestamp "\t" filename
}' | sort -nr | head -1 | {
    read max_timestamp filename
    echo "Имя файла: $filename"
    echo "Полный URL: ${url}${filename}"
}
