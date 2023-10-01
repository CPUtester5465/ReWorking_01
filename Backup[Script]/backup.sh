#!/bin/bash

# Параметры по умолчанию
BACKUP_DIR="/path/to/backup/directory" # Директория для хранения бэкапов
USERNAME="username" # Пользователь
SERVER_IP="192.168.0.1" # IP адрес удаленного сервера
DEBUG_MODE=false # Режим отладки (true/false)
DIRECTORIES=("/dir1" "/dir2") # Директории, которые будут скопированы с удаленного сервера
BACKUP_TYPE="full" # Тип бэкапа (full/incremental)

# Функция для вывода справки
usage() {
  echo "Usage: backup.sh [-h] [-d BACKUP_DIR] [-u USERNAME] [-s SERVER_IP] [-D] [-i DIRECTORY]... [-t TYPE]"
  echo "Options:"
  echo "-h            Show help message"
  echo "-d BACKUP_DIR Set backup directory (default: /path/to/backup/directory)"
  echo "-u USERNAME   Set username for remote server connection (default: username)"
  echo "-s SERVER_IP  Set IP address of remote server (default: server_ip)"
  echo "-D            Enable debug mode"
  echo "-i DIRECTORY  Add directory to be backed up (multiple directories can be added)"
  echo "-t TYPE       Set backup type (full or incremental, default: full)"
  exit 1
}

# Обработка аргументов командной строки
while getopts "hd:u:s:Di:t:" opt; do
  case ${opt} in
    h)
      usage
      ;;
    d)
      BACKUP_DIR=${OPTARG}
      ;;
    u)
      USERNAME=${OPTARG}
      ;;
    s)
      SERVER_IP=${OPTARG}
      ;;
    D)
      DEBUG_MODE=true
      ;;
    i)
      DIRECTORIES+=("${OPTARG}")
      ;;
    t)
      BACKUP_TYPE="${OPTARG}"
      ;;
    \?)
      echo "Invalid Option: -$OPTARG" 1>&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." 1>&2
      exit 1
      ;;
  esac
done

# Проверка обязательных аргументов
if [ -z "$BACKUP_DIR" ] || [ -z "$USERNAME" ] || [ -z "$SERVER_IP" ] || [ -z "$DIRECTORIES" ]; then
  echo "Missing required arguments" 1>&2
  exit 1
fi

# Функция для проверки наличия зависимостей (rsync, gzip, openssl)
check_dependencies() {
  if ! command -v rsync >/dev/null 2>&1; then
    echo "Ошибка: rsync не установлен." >&2
    exit 1
  fi

  if ! command -v gzip >/dev/null 2>&1; then
    echo "Ошибка: gzip не установлен." >&2
    exit 1
  fi

  if ! command -v openssl >/dev/null 2>&1; then
    echo "Ошибка: openssl не установлен." >&2
    exit 1
  fi
}

check_dependencies

# Функция для выполнения полного бэкапа
perform_full_backup() {
  # Создаем папки для бэкапа
  mkdir -p "$BACKUP_DIR/Full"
  mkdir -p "$BACKUP_DIR/FullOld"

  # Копируем данные с удаленного сервера и сохраняем в зашифрованном и сжатом виде
  rsync -az --delete --progress -e "ssh" "$USER@$SERVER_IP:$REMOTE_DIRS" | gzip | openssl enc -aes-256-cbc -salt -out "$BACKUP_DIR/Full/backup.tar.gz.enc"

  # Удаляем старые версии бэкапов
  mv "$BACKUP_DIR/Full/backup.tar.gz.enc" "$BACKUP_DIR/FullOld/backup.tar.gz.enc"
  rm -rf "$BACKUP_DIR/FullOld/backup.tar.gz.enc"
}

# Функция для выполнения инкрементального бэкапа
perform_incremental_backup() {
  # Создаем папки для бэкапа
  mkdir -p "$BACKUP_DIR/Inc"
  mkdir -p "$BACKUP_DIR/IncOld"

  # Копируем данные с удаленного сервера и сохраняем в зашифрованном и сжатом виде
  rsync -az --delete --progress --backup --backup-dir="$BACKUP_DIR/IncOld" -e "ssh" "$USER@$SERVER_IP:$REMOTE_DIRS" | gzip | openssl enc -aes-256-cbc -salt -out "$BACKUP_DIR/Inc/backup.tar.gz.enc"

  # Удаляем старые версии бэкапов
  mv "$BACKUP_DIR/Inc/backup.tar.gz.enc" "$BACKUP_DIR/IncOld/backup.tar.gz.enc"
  rm -rf "$BACKUP_DIR/IncOld/backup.tar.gz.enc"
}


# Проверка и создание директории для хранения бэкапов
if [[ ! -d "$BACKUP_DIR" ]]; then
  mkdir -p "$BACKUP_DIR"
fi

# Вывод текущих параметров, если запущен в режиме debug
if [[ $DEBUG_MODE == true ]]; then
  echo "Параметры:"
  echo "  Директория для хранения бэкапов: $BACKUP_DIR"
  echo "  Пользователь: $USERNAME"
  echo "  Сервер: $SERVER_IP"
  echo "  Директории для копирования: ${DIRECTORIES[*]}"
  echo "  Режим отладки: $DEBUG_MODE"
  echo "  Backup Type: $BACKUP_TYPE"
fi


if [[ $BACKUP_TYPE == "full" ]]; then
  perform_full_backup
elif [[ $BACKUP_TYPE == "incremental" ]]; then
  perform_incremental_backup
else
  echo "Ошибка: некорректный тип бэкапа. Используйте full или incremental." >&2
  exit 1
fi

# Завершение скрипта
debug "Backup completed."
exit 0

