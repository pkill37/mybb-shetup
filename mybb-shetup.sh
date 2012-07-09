#!/bin/bash

# Clear terminal and cd to /

clear

# Obtain the download path from the user

echo ":: Enter the absolute path where MyBB should be downloaded and extracted to:"

read DOWNLOADPATH

# If the path exists, cd to it. Otherwise ask the user if he wants to create it

if [[ -d $DOWNLOADPATH ]]; then
	cd $DOWNLOADPATH
else
	echo ":: The path you specified does not exist. Do you want to create it? [Y/n]"

	read CREATEPERM

	# If user responded yes, create the directory and cd to it. Otherwise exit

	if [[ $CREATEPERM == Y || $CREATEPERM == y ]]; then
		echo "Creating $DOWNLOADPATH..."
		mkdir $DOWNLOADPATH
		cd $DOWNLOADPATH
	else
		echo "You chose not to create the path. Aborting..."
		sleep 5
		exit 1
	fi
fi

sleep 2

# Download MyBB using wget. Fallback to curl and lynx. Exit if all else fails.

echo "Initiating download..."

command wget --content-disposition http://www.mybb.com/download/latest -O mybb.zip  >/dev/null 2>&1 ||
{
	command curl http://www.mybb.com/download/latest -o mybb.zip  >/dev/null 2>&1 ||
	{
		command lynx -crawl -dump http://www.mybb.com/download/latest > mybb.zip  >/dev/null 2>&1 ||
		{
			echo "wget, curl or lynx is required to download MyBB. Aborting..."
			sleep 5
			exit 1
		}
	}
}

# Unzip, clean things up and CHMOD required files

unzip mybb.zip "Upload/*"
mv Upload/* .
rm -Rf Upload mybb.zip
mv inc/config.default.php inc/config.php
chmod -R 0777 cache uploads inc/settings.php inc/config.php

############
### TODO ###
############

#echo ":: MyBB is ready to be installed. Do you want to open your web browser? [Y/n]"

#read BROWSERPERM