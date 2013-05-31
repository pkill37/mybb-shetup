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
    prompt_input "Where would you like to install MyBB to (FULL PATH)?" "" INSTALL_DIR

    if [[ -d "$INSTALL_DIR" ]] ; then
        cd $INSTALL_DIR
    else
        if prompt_yn "The path you entered does not exist. Would you like to create it?" "Y"; then
            info "Creating $INSTALL_DIR..."
            mkdir -p $INSTALL_DIR
            cd $INSTALL_DIR
            INSTALL_ROOT=$(pwd)
        else
            abort "Declined option to create path. Canceling installation."
        fi
    fi  
}

branch_select() {
    prompt_input "What branch would you like to download?" "MASTER/stable/feature" BRANCH
}

command_pick() {
    if command_exists git ; then
        DLCOMMAND="git clone https://github.com/mybb/mybb.git -b $BRANCH"
        COMMAND_USED="git"
    elif command_exists wget ; then
        DLCOMMAND="wget --content-disposition https://github.com/mybb/mybb/archive/$BRANCH.zip"
        COMMAND_USED="wget"
    elif command_exists curl ; then
        DLCOMMAND="curl https://github.com/mybb/mybb/archive/$BRANCH.zip -o mybb.zip"
        COMMAND_USED="curl"
    elif command_exists lynx ; then
        DLCOMMAND="lynx -crawl -dump https://github.com/mybb/mybb/archive/$BRANCH.zip > mybb.zip"
        COMMAND_USED="lynx"
    else
        abort "git, wget, curl, or lynx are required to install MyBB. Please install one and try again."
    fi
}

install_confirm() {
    if prompt_yn "Do you want to install MyBB $BRANCH to $INSTALL_DIR?" "Y"; then
        download
    else
        abort "Aborting by user choice."
    fi
}

download() {
    pick_command
    if [ $COMMAND_USED = "git" ] ; then
        $DLCOMMAND
    else
        $DLCOMMAND
        if command_exists unzip ; then
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
    # Get root pass
    info "To create a database for you, we need some high-level privileges temporarily."

    prompt_input "We assume your MySQL server has a root user, what is its password?" "" ROOTPASS
    # create/select DB
    prompt_input "What should the name of the database be? It should not already exist." "mybb" DBNAME
    mysql -uroot -p $ROOTPASS -e "CREATE DATABASE '$DBNAME';"
    # create mybb db user
    prompt_input "What should the username be for the regular DB user that MyBB will use?" "mybb" DBUSER

    prompt_input "Great! What should its password be? []: " DBPASS
    mysql -uroot -p $ROOTPASS -e "CREATE USER '$DBUSER'@'localhost' IDENTIFIED BY '$DBPASS';"
    # grant mybb db user permissions
    mysql -uroot -p $ROOTPASS -e "GRANT ALL ON $DBNAME.* TO '$DBUSER'@'localhost';"
}

php_server_start() {
    prompt_input "What hostname would you like to use for the PHP 5.4 server?" "localhost" HOSTNAME
    prompt_input "What port would you like to host the PHP 5.4 server on?" "8000" PORT

    php -S $HOSTNAME:$PORT
}

browser_open() {
    URL="http://$HOSTNAME:$PORT/install"

    if command_exists xdg-open ; then # Linux
        xdg-open $URL
    else # OSX
        open $URL
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
