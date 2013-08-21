pause() {
    read -p "$*"
}

abort() {
    echo "$1"
    sleep 1
    exit 1
}

info() {
    echo "$1"
    sleep 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

shell_current() {
    ps -p $$ -o cmd="" | cut -d ' ' -f1
}