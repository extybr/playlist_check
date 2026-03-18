#!/bin/bash
# ./playlist_cleaner.sh <файл.m3u>
# Удаление дубликатов строк и поиск аномалий в структуре плейлиста

INPUT_FILE="$1"

if [ -z "$INPUT_FILE" ]; then
    echo "Использование: $0 <файл.m3u>"
    exit 1
fi

DIR=$(dirname "$INPUT_FILE")
BASE=$(basename "$INPUT_FILE")
TEMP_FILE="${DIR}/cleaned_${BASE}"

# Удаление дубликатов
awk '{gsub(/[ \t]+$/, ""); if (!seen[$0]++) print}' "$INPUT_FILE" > "$TEMP_FILE"
echo "✅ Удаление дубликатов "

# Поиск аномалий и сохранение результата
echo -e "\n=== 💊 \033[36mПОИСК СТРУКТУРНЫХ ОШИБОК\033[0m ===\n"
ERRORS=$(awk '
/^#EXTINF:/ {
    if (prev ~ /^#EXTINF:/) {
        print "❌ Два #EXTINF подряд: строки " NR-1 " и " NR
        print "  " prev
        print "  " $0
        print ""
    }
}
/^http/ {
    if (prev ~ /^http/) {
        print "❌ Два http подряд: строки " NR-1 " и " NR
        print "  " prev
        print "  " $0
        print ""
    }
}
{prev=$0}
' "$TEMP_FILE")

# Выводим найденные ошибки
if [ -n "$ERRORS" ]; then
    echo "$ERRORS"
    
    echo -e "\n=== 🛠  \033[36mРЕКОМЕНДАЦИИ ПО ИСПРАВЛЕНИЮ\033[0m ===\n"
    echo "$ERRORS" | grep "Два .* подряд:" | while read line; do
        if [[ $line == *"#EXTINF"* ]]; then
            echo "➡️  ${line} - удалить верхнюю строку"
        elif [[ $line == *"http"* ]]; then
            echo "➡️  ${line} - удалить верхнюю строку"
        fi
    done
    echo ""
    echo "💾 Файл для редактирования: $TEMP_FILE"
else
    echo "Ошибок не найдено"
fi

# Статистика
ORIGINAL_LINES=$(wc -l < "$INPUT_FILE")
CLEANED_LINES=$(wc -l < "$TEMP_FILE")
REMOVED=$((ORIGINAL_LINES - CLEANED_LINES))

echo -e "\n=== ⚙️  \033[36mСТАТИСТИКА\033[0m ===\n"
echo "Исходный файл: $ORIGINAL_LINES строк"
echo "Очищенный файл: $CLEANED_LINES строк"
echo "Удалено дубликатов: $REMOVED"

