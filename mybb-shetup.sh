#!/bin/bash

cd

echo "Enter the absolute path where MyBB should be downloaded and extracted to:"

read DOWNLOADPATH

if [[ -d "$DOWNLOADPATH" ]]; then
	cd $DOWNLOADPATH

else
	echo "The path you specified does not exist. Do you want to create it? [Y/n]"

	read createperm

	if [[ "$createperm" == Y || "$createperm" == y ]]; then
		echo "Creating $DOWNLOADPATH..."
		mkdir $DOWNLOADPATH
		cd $DOWNLOADPATH
	else
		echo "Aborting..."
		exit 1
	fi
fi

echo "Initiating download..."

command wget --content-disposition http://www.mybb.com/download/latest -O mybb.zip  >/dev/null 2>&1 || {
	command curl http://www.mybb.com/download/latest -o mybb.zip  >/dev/null 2>&1 || {
		command lynx -crawl -dump http://www.mybb.com/download/latest > mybb.zip  >/dev/null 2>&1 || {
			echo "wget, curl or lynx are required to download MyBB. Please install either one of them." exit 1;
		}
	}
}

# Unzip and CHMOD

unzip mybb.zip "Upload/*"
mv Upload/* .
rm -Rf Upload mybb.zip
mv inc/config.default.php inc/config.php
chmod -R 0777 cache uploads inc/settings.php inc/config.php