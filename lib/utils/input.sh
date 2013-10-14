input_yn() {
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

input_reply() {
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