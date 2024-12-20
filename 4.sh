#!/bin/bash

# Функции для выполнения действий
list_users() {
  cut -d: -f1,6 /etc/passwd | sort | tr ":" "\t"
}

list_processes() {
  ps -eo pid,comm --sort=pid
}

display_help() {
  cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
  -u, --users       Вывод списка пользователей и их домашних директорий
  -p, --processes   Вывод списка запущенных процессов
  -h, --help        Вывод этой справки
  -l PATH, --log PATH
                    Перенаправление вывода в файл по указанному пути
  -e PATH, --errors PATH
                    Перенаправление ошибок в файл по указанному пути
EOF
}

# Переменные для обработки аргументов
log_file=""
error_file=""

# Парсинг аргументов командной строки
TEMP=$(getopt -o uphl:e: --long users,processes,help,log:,errors: -n "$0" -- "$@")
if [ $? != 0 ]; then
  echo "Ошибка при разборе аргументов" >&2
  exit 1
fi
eval set -- "$TEMP"

# Обработка аргументов
while true; do
  case "$1" in
    -u|--users)
      action="users"
      shift ;;
    -p|--processes)
      action="processes"
      shift ;;
    -h|--help)
      action="help"
      shift ;;
    -l|--log)
      log_file="$2"
      shift 2 ;;
    -e|--errors)
      error_file="$2"
      shift 2 ;;
    --)
      shift
      break ;;
    *)
      echo "Неизвестный аргумент: $1" >&2
      exit 1 ;;
  esac
done

# Проверка доступности файлов (если указаны)
if [[ -n "$log_file" ]]; then
  if ! touch "$log_file" 2>/dev/null; then
    echo "Ошибка доступа к файлу лога: $log_file" >&2
    exit 1
  fi
fi

if [[ -n "$error_file" ]]; then
  if ! touch "$error_file" 2>/dev/null; then
    echo "Ошибка доступа к файлу ошибок: $error_file" >&2
    exit 1
  fi
fi

# Выполнение действия
{
  case "$action" in
    users)
      list_users
      ;;
    processes)
      list_processes
      ;;
    help)
      display_help
      ;;
    *)
      echo "Неизвестное действие" >&2
      exit 1
      ;;
  esac
} > "${log_file:-/dev/stdout}" 2> "${error_file:-/dev/stderr}"
