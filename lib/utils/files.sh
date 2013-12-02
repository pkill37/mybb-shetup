files_unfold() {
    mv mybb/* .
}

files_config_rename() {
    mv inc/config.default.php inc/config.php
}

files_chmod() {
    chmod -R 777 cache/
    chmod -R 777 uploads/
    chmod 666 inc/config.php
    chmod 666 inc/settings.php
}