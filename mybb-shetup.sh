#!/usr/bin/env bash

set -e

#############################################################################
## Generic helper functions
#############################################################################

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

php_version() {
    php -v | head -n 1 | cut -d ' ' -f2 | cut -d '-' -f1;
}

shell_current() {
    ps -p $$ -o cmd="" | cut -d ' ' -f1
}

prompt_yn() {
    local question="$1" # Question to be prompted to the user
    local default="$2" # Default reply (Y or N)

    # Loop until a valid reply is given
    while true; do

        # Set a default reply from argument
        if [ "${default:-}" = "Y" ]; then
            local prompt="Y/n"
        elif [ "${default:-}" = "N" ]; then
            local prompt="y/N"
        else
            local prompt="y/n"
        fi
 
        # 100% portable solution to prompt the user
        echo -n "$question [$prompt]"
        local reply
        read reply

        # If the user just hit enter he wants the default reply
        if [ -z "$reply" ]; then
            reply=$default
        fi
 
        # Check reply
        case "$reply" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac

    done
}

prompt_input() {
    local question="$1" # Question to prompt user for input
    local options="$2" # List of possible options
    local varname="$3" # Name of the variable to be returned

    # The all-caps word in $options is the default reply
    local default_reply=$(echo $options | tr -dc '[:upper:]' | tr '[:upper:]' '[:lower:]')
    
    # Prompt the user with the question and options
    echo -n "$question [$options]"
    read $varname

    # Temporary variable to allow checking if no input was provided
    eval varname_tmp=\$$varname

    # If the user just hit enter he wants the default reply
    if [ -z "$varname_tmp" ]; then
        eval "$varname=$default_reply"
    fi
}

#############################################################################
## Script functions
#############################################################################

welcome_ascii_art() {
    echo "
      __  __       ____  ____  
     |  \/  |     |  _ \|  _ \ 
     | \  / |_   _| |_) | |_) |
     | |\/| | | | |  _ <|  _ < 
     | |  | | |_| | |_) | |_) |
     |_|  |_|\__, |____/|____/ 
              __/ |            
             |___/             
    "
    echo "
    Because free never tasted so good!

    "
}

welcome_message() {
    welcome_ascii_art

    info "Welcome to mybb-shetup, the MyBB shell installer. This script will help you set up a copy of MyBB in a minute!"    
    pause "Press [ENTER] to continue... or press CTRL+C to quit."

    clear
}

dir_select() {
    prompt_input "Where would you like to install MyBB to (FULL PATH)?" "" install

    if [ -d "$install" ]; then
        cd $install
    else
        if prompt_yn "The path you entered does not exist. Would you like to create it?" "Y"; then
            info "Creating $install..."
            mkdir -p $install
            cd $install
            install_root=$(pwd)
        else
            abort "Declined option to create path. Canceling installation."
        fi
    fi  
}

branch_select() {
    prompt_input "What branch would you like to download?" "MASTER/stable/feature" branch
}

command_pick() {
    if command_exists git; then
        download_command="git clone https://github.com/mybb/mybb.git -b $branch"
        download_command_used="git"
    elif command_exists wget; then
        download_command="wget --content-disposition https://github.com/mybb/mybb/archive/$branch.zip"
        download_command_used="wget"
    elif command_exists curl; then
        download_command="curl https://github.com/mybb/mybb/archive/$branch.zip -o mybb.zip"
        download_command_used="curl"
    elif command_exists lynx; then
        download_command="lynx -crawl -dump https://github.com/mybb/mybb/archive/$branch.zip > mybb.zip"
        download_command_used="lynx"
    else
        abort "git, wget, curl, or lynx are required to install MyBB. Please install one and try again."
    fi
}

install_confirm() {
    if prompt_yn "Do you want to install MyBB $branch to $install_dir?" "Y"; then
        download
    else
        abort "Aborting by user choice."
    fi
}

download() {
    pick_command
    if [ $download_command_used = "git" ]; then
        $download_command
    else
        $download_command
        if command_exists unzip; then
            unzip mybb.zip
        else
            abort "Unzip is required to install MyBB. Please install it using your package manager"
        fi
    fi      
}

files_unfold() {
    mv mybb/* .
}

config_rename() {
    mv inc/config.default.php inc/config.php
}

files_chmod() {
    chmod -R 777 cache/
    chmod -R 777 uploads/
    chmod 666 inc/config.php
    chmod 666 inc/settings.php
}

database_create() {
    info "To create a database for you, we need some high-level privileges temporarily."

    # Get root pass
    prompt_input "We assume your MySQL server has a root user, what is its password?" "" root_pass
    
    # Create database
    prompt_input "What should the name of the database be? It should not already exist." "mybb" db_name
    mysql -uroot -p $root_pass -e "CREATE DATABASE '$db_name';"

    # Create database user
    prompt_input "What should the username be for the regular DB user that MyBB will use?" "mybb" db_user
    prompt_input "Great! What should its password be? []: " db_pass
    mysql -uroot -p $root_pass -e "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pass';"

    # Grant permissions to database user
    mysql -uroot -p $root_pass -e "GRANT ALL ON $db_name.* TO '$db_user'@'localhost';"
}

php_server_start() {
    prompt_input "What hostname would you like to use for the PHP 5.4 server?" "localhost" server_hostname
    prompt_input "What port would you like to host the PHP 5.4 server on?" "8000" server_port

    php -S $server_hostname:$server_port
}

browser_open() {
    url="http://$server_hostname:$server_port/install"

    if command_exists xdg-open; then # Linux
        xdg-open $url
    else # OSX
        open $url
    fi
}

#############################################################################
## Bootstrap installer
#############################################################################

main() {
    welcome_message
    dir_select
    branch_select
    install_confirm
    files_unfold
    config_rename
    files_chmod
}

main "$@"
