#!/bin/bash

# Clear terminal and cd to /

clear
cd /

# Obtain the download path from the user

echo "Enter the absolute path where MyBB should be downloaded and extracted to:"
read DOWNLOADPATH

# If the path exists, cd to it. Otherwise ask the user if he wants to create it

if [[ -d "$DOWNLOADPATH" ]]; then
	cd $DOWNLOADPATH
else
	echo "The path you specified does not exist. Do you want to create it? [Y/n]"
	read CREATEPERM

	# Translate answer to lowercase
	CREATEPERMLOWER=$( echo "$CREATEPERM" | tr -s  '[:upper:]'  '[:lower:]' )

	# If user responded yes, create the directory and cd to it. Otherwise exit

	if [[ $CREATEPERMLOWER == y || $CREATEPERMLOWER == yes ]]; then
		echo ":: Creating $DOWNLOADPATH..."
		sleep 1
		mkdir $DOWNLOADPATH
		cd $DOWNLOADPATH
	else
		echo ":: You chose not to create the path. Aborting..."
		exit 1
	fi
fi

# Download MyBB using wget. Fallback to curl and lynx. Exit if all else fails.

echo ":: Initiating download..."
sleep 1

command wget --content-disposition http://www.mybb.com/download/latest -O mybb.zip  >/dev/null 2>&1 ||
{
	command curl http://www.mybb.com/download/latest -o mybb.zip  >/dev/null 2>&1 ||
	{
		command lynx -crawl -dump http://www.mybb.com/download/latest > mybb.zip  >/dev/null 2>&1 ||
		{
			echo ":: wget, curl or lynx is required to download MyBB. Aborting..."
			exit 1
		}
	}
}

# Extract, clean things up and CHMOD required files

echo ":: Extracting..."
sleep 1
unzip mybb.zip "Upload/*"

echo ":: Cleaning up..."
sleep 1
mv Upload/* .
rm -Rf Upload mybb.zip
mv inc/config.default.php inc/config.php

echo ":: CHMOD files..."
sleep 1
chmod -R 0777 cache uploads inc/settings.php inc/config.php

echo ":: Success! MyBB is ready to be installed."

# TODO: Open web browser for installation (?)
