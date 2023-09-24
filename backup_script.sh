# Параметры по умолчанию
backup_dir="/path/to/backup/dir"
user="username"
server="1.2.3.4"
debug=false
directories=("/dir1" "/dir2")
full_backup=false

# Функция для вывода справки
usage() {
  echo "Usage: backup_script.sh [OPTIONS]"
  echo "Options:"
  echo "  -d, --backup-dir <directory>   Directory to store backups (default: /path/to/backup/dir)"
  echo "  -u, --user <username>          User for connecting to the server (default: username)"
  echo "  -s, --server <ip>              Server to connect for backup (default: 1.2.3.4)"
  echo "  -D, --debug                    Run the script in debug mode"
  echo "  -D, --directories <dir1 dir2>  Directories to backup from the remote server (default: /dir1 /dir2)"
  echo "  -f, --full                     Perform a full backup instead of incremental backup"
  echo "  -h, --help                     Show help"
}

# Парсинг аргументов командной строки
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -d|--backup-dir)
      backup_dir="$2"
      shift
      shift
      ;;
    -u|--user)
      user="$2"
      shift
      shift
      ;;
    -s|--server)
      server="$2"
      shift
      shift
      ;;
    -D|--debug)
      debug=true
      shift
      ;;
    -D|--directories)
      directories=("$2")
      shift
      shift
      ;;
    -f|--full)
      full_backup=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

# Функция для выполнения бекапа
perform_backup() {
  if [ "$debug" = true ]; then
    echo "Performing backup..."
  fi

  # Команда для копирования данных с удаленного сервера в зашифрованном, сжатом виде
  rsync -avz --compress-level=9 --progress --delete -e "ssh -o StrictHostKeyChecking=no" "$user@$server:${directories[@]}" "$backup_dir"

  if [ "$debug" = true ]; then
    echo "Backup completed."
  fi
}

# Выполнение бекапа
perform_backup

# Ротация устаревших версий с использованием logrotate
if [ "$full_backup" = true ]; then
  logrotate -f /etc/logrotate.d/full_backup.conf
else
  logrotate -f /etc/logrotate.d/incremental_backup.conf
