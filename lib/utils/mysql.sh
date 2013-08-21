mysql_location() {
    if command_exists mysql; then
        mysql_executable="mysql"
    else
        echo "We could not find the location of the MySQL executable. We need some help here."
        prompt_input "Where is the MySQL executable located? Full path required." mysql_executable
    fi
}

mysql_run_commands() {

    # Get root pass
    prompt_input "We assume your MySQL server has a root user, what is its password?" "" root_pass
    
    # Create database
    prompt_input "What should the name of the database be? It should not already exist." "mybb" db_name
    $mysql_executable -uroot -p $root_pass -e "CREATE DATABASE '$db_name';"

    # Create database user
    prompt_input "What should the username be for the regular DB user that MyBB will use?" "mybb" db_user
    prompt_input "Great! What should its password be? []: " db_pass
    $mysql_executable -uroot -p $root_pass -e "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pass';"

    # Grant permissions to database user
    $mysql_executable -uroot -p $root_pass -e "GRANT ALL ON $db_name.* TO '$db_user'@'localhost';"
}

mysql_setup() {
    info "To create a database for you, we need some high-level privileges temporarily."
    info "Attempting to find the MySQL executable... Please wait."
    sleep 1

    mysql_location
    if [ -f $mysql_executable ]; then
        mysql_run_commands; #It works. Continue.
    else
        mysql_location #Try again
    fi
}