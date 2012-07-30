# mybb-shetup

Don't use this yet. Bash script that downloads MyBB and prepares it to be installed.

## Requirements

- Linux/Mac OS
- git
- wget, curl or lynx
- PHP >= 5.4

## Features

- Clones any branch from the MyBB repository if you want the latest
- Downloads older versions from GitHub tags if you need it
- Extracts archive if you downloaded an older version
- Renames inc/config.default.php to inc/config.php
- CHMOD necessary files
- Creates MySQL database and database user
- Starts PHP 5.4's development server on a custom port
- Opens the browser on the install directory

## Installation

mybb-shetup is just a bash script. You can download it however you like. Our suggestion is that you clone the repository and move the script to your `/usr/local/bin/` directory so that you can easily use `mybbshetup` globally.

	$ git clone https://github.com/faviouz/mybb-shetup.git
	$ cd mybb-shetup
	$ mv mybb-shetup.sh /usr/local/bin/mybbshetup

Afterwards you can get rid of the cloned repository.

	$ cd ..
	$ rm -rf mybb-shetup

## Usage

### Quick start

To use mybb-shetup open up a terminal and run:

	$ mybbshetup

Follow the instructions.

### Passing arguments

If you don't want to go through the wizard you can simply pass the options as arguments to the `mybbshetup` command.

### Aliases

You can set up an alias for the script with whatever arguments you like. For example, this is handy if you're only ever going to want to install the latest MyBB and don't want to go through the wizard every time or pass in arguments to the command manually.

	alias installmybb = 'mybbshetup feature ~/Projects'

### Workflow

To get a real feeling of how this will improve your workflow when developing for MyBB, take a look at this small video we've prepared.
