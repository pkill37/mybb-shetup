php_version() {
    php -v | head -n 1 | cut -d ' ' -f2 | cut -d '-' -f1;
}

php_server_start() {
    input_reply "What hostname would you like to use for the PHP 5.4 server?" "localhost" server_hostname
    input_reply "What port would you like to host the PHP 5.4 server on?" "8000" server_port

    php -S $server_hostname:$server_port
}