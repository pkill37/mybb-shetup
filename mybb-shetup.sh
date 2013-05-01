#!/bin/bash

###############################
# FUNCTIONS
###############################
function pause(){
   read -p "$*"
}

function confirm_install() {
    # call with a prompt string or use a default
    read -r -p "Do you want to install MyBB $BRANCH to $INSTALL_DIR? []" response
    case $response in
        [yY][eE][sS]|[yY]) 
            download
            ;;
        *)
            echo "Aborting by user choice."
            exit 1
            ;;
    esac
}

function dir_select(){
	read -p "Where would you like to install MyBB to (FULL PATH)? []: " INSTALL_DIR
	if [[ -d "$INSTALL_DIR" ]] ; then
		cd $INSTALL_DIR
	else
		read -p "The path you entered does not exist. Would you like to create it? [Y/n]" CREATEPERM

		# Turn to lowercase
		CREATEPERMLOWER=$( echo "$CREATEPERM" | tr -s  '[:upper:]'  '[:lower:]' )

		if [[ $CREATEPERMLOWER == y || $CREATEPERMLOWER == yes ]]; then
			echo "Creating $INSTALL_DIR..."
			sleep 1
			mkdir -p $INSTALL_DIR
			cd $INSTALL_DIR
			INSTALL_ROOT=`pwd`
		else
			echo "Declined option to create path. Canceling installation."
			exit 1
		fi
	fi	


}
function select_branch(){
	read -p "What branch would you like to download? [MASTER/feature/stable]: " BRANCH
}
function command_exists(){
	type "$1" &> /dev/null ;
}
function pick_command(){
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
		echo "git, wget, curl, or lynx are required to install MyBB. Please install one and try again."
		exit 1
	fi
}
function download(){
	pick_command
	if [ $COMMAND_USED = "git" ] ; then
		`$DLCOMMAND`
	else
		`$DLCOMMAND`
		if command_exists unzip ; then
			unzip mybb.zip
		else
			echo "Unzip is required to install MyBB. Please install it using your package manager"
			exit 1
		fi
	fi		

}
function create_database() {
	# Get root pass
	echo "To create a database for you, we need some high-level privileges temporarily."
	sleep 3
	read -p "We assume your MySQL server has a root user, what is its password? []: " ROOTPASS
	# create/select DB
	read -p "What should the name of the database be? It should not already exist. [mybb]: " DBNAME
	mysql -uroot -p`$ROOTPASS` -e "CREATE DATABASE '`$DBNAME`';"
	# create mybb db user
	read -p "What should the username be for the regular DB user that MyBB will use? [mybb]: " DBUSER
	sleep 1
	read -p "Great! What should its password be? []: " DBPASS
	mysql -uroot -p`$ROOTPASS` -e "CREATE USER '`$DBUSER`'@'localhost' IDENTIFIED BY '`$DBPASS`';"
	# grant mybb db user permissions
	mysql -uroot -p`$ROOTPASS` -e "GRANT ALL ON `$DBNAME`.* TO '`$DBUSER`'@'localhost';"
}

function unfold_files()
{
	mv mybb/* .
}
function rename_config(){
	mv inc/config.default.php inc/config.php
}
function chmod_files(){
	chmod -R 777 cache/
	chmod -R 777 uploads/
	chmod 666 inc/config.php
	chmod 666 inc/settings.php
}
function display_ascii_art(){
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
	echo "Because free never tasted so good!

	"
}
###############################
#START INSTALLER
###############################

display_ascii_art
pause "Press [ENTER] to continue... or press CTRL+C to quit."

# Say "Initializing" and sleep for 2 seconds. Just because it seems cool.
clear
echo ":: INITIALIZING"
sleep 1
echo "Welcome to the MyBB shell installer. This script will help you set up a copy of MyBB in under a minute!."
clear

dir_select
select_branch
confirm_install
unfold_files
rename_config
chmod_files