#!/bin/bash

putb=$1  # путь до файла или папки
N=$2     # порог архивирования
backup=$3  # папка для архива

# Проверяем процент заполненности для переданной папки
isp=$(df "$putb" | tail -1 | awk '{print $5}' | sed 's/%//')
echo "$isp% использовано"

# Если процент заполненности превышает порог
if [ "$isp" -gt "$N" ]; then
  echo "Пошла архивация"

  # Цикл продолжается, пока заполненность больше порога
  while [ "$isp" -gt "$N" ]; do


    file_to_archive=$(find "$putb" -type f -printf "%T@ %p\n" | sort -n | head -n 1 | cut -d' ' -f2)
    file_name=$(basename "$file_to_archive" .log)
    namea="backup_"$file_name".tar.gz"  # имя архива
    # Проверяем, есть ли файлы для архивации
    if [ -z "$file_to_archive" ]; then
      echo "Нет файлов для архивации"
      exit 1
    fi

    # Архивируем файлы
    tar -czvf "$backup/$namea" $(find "$putb" -type f -printf "%T@ %p\n" | sort -n | head -n 1 | cut -d' ' -f2)
    # Удаляем архивированные файлы
    rm -f "$file_to_archive"

    # Пересчитываем заполненность диска
    isp=$(df "$putb" | tail -1 | awk '{print $5}' | sed 's/%//')
  done

  echo " успешно "

else
  echo "все и так нормикс"
fi
