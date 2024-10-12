#!/bin/bash


echo "введите путь до папки, которую проверяем"
read putb
mkdir -p "$putb" 

#создание образа диска ограниченного объема
path1=$(dirname "$putb")
dd if=/dev/zero of="$path1"/test.img bs=1M count=10240
mkfs.ext4 "$path1"/test.img
mount -o loop "$path1"/test.img "$putb"

#ввод значений от пользователя
echo "введите пороговый процент заполненности"
read THRESHOLD

echo "введите путь до папки с архивами"
read backupputb
mkdir -p "$backupputb"  # создание директории для архивов

#заполняем папку файлами для тестов
echo "Создание тестовых файлов"
TEST_SIZE=7240  # размер файлов для  тестов
TEST_FILE_COUNT=15  # Количество тестовых файлов

for i in $(seq 1 "$TEST_FILE_COUNT"); do
  dd if=/dev/zero of="$putb/testfile$i.log" bs=1M count=$(($TEST_SIZE / $TEST_FILE_COUNT))
done

./firstscr.sh "$putb" $THRESHOLD $backupputb # вызываем первый скрипт


USAGE=$(df "$putb" | tail -1 | awk '{print $5}' | sed 's/%//')  # процент занятого места

echo "Тест 1: Проверка архивации при превышении порога"

if [[ $(ls -A "$backupputb" | wc -l) != "0" || "$USAGE" -le "$THRESHOLD" ]]; then
  echo "пройден"
else
  echo "не пройден"
fi

echo "Тест 2: Проверка заполненности папки"

if [ "$USAGE" -le "$THRESHOLD" ]; then
  echo "пройден"
  echo "$USAGE% заполненность"
else
  if [[ "$THRESHOLD" -eq 0 && $(ls -A "$putb" | wc -l) != "0" ]]; then
    echo "пройден"
    echo "$USAGE% заполненность"
  else
    echo "не пройден"
    echo "$USAGE% заполненность"
  fi
fi
