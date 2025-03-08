#!/bin/bash
##!/usr/bin/bash

# Execute me : 
# 	bash ~/github/scripts/kill-game.sh <process_name_list>

# v.0.1 ChatGPT initial version
# v.0.2 Clean code with Cursor - AI Code Editor

# Purpose: this script kills all instances of all the processes listed as argument. useful to kill several processes running in parallel. the script will kill all these instances with SIGTERM (graceful termination) first, then wait a bit , then kill them with SIGINT (interrupt signal) , then wait a bit ,then kill them with SIGKILL (force termination). Hence the nested ifs. 

# Define constants
readonly SUCCESS="\e[32m"
readonly ERROR="\e[31m"
readonly INFO="\e[35m" # MAGENTA
readonly BOLD="\e[1m"
readonly RESET="\e[0m"
# Get the PID of the current script
readonly SCRIPT_PID=$$
readonly SLEEP_DURATION=2
readonly SIGNALS=("SIGTERM" "SIGINT" "SIGKILL")

# Helper function to log messages with colors
log_message() {
    local level=$1
    local message=$2
    local color

    case $level in
        "SUCCESS") color=$SUCCESS ;;
        "ERROR") color=$ERROR ;;
        "INFO") color=$INFO ;;
        *) color=$RESET ;;
    esac

    echo -e "${color}${level}: ${message}${RESET}"
}

count_running_process() {
	local process_name=$1
	# pgrep -f "$process_name" | grep -v "^$SCRIPT_PID$" || true
    pkill --older 20 --count "$process_name"

}

# Function to kill a single process with escalating signals
kill_process() {
    local process_name=$1
    
    # Display the process to kill
    log_message "INFO" "Process to kill: ${BOLD}$process_name"
    
    # Count the number of processes
    count=$(count_running_process "$process_name")
    # log_message "INFO" "count_running_process $process_name : $count"

    # Check if process exists before attempting to kill
    if [ $count -eq 0 ]; then
        log_message "INFO" "Process '$process_name' not found"
        return 0
    fi

    # Try each signal in sequence until process is killed
    for signal in "${SIGNALS[@]}"; do
        pkill --older 20 --echo --signal "$signal" "$process_name"
   		# Wait for a short time to allow the kill to take effect
        sleep "$SLEEP_DURATION"

        if [ $(count_running_process "$process_name") -eq 0 ]; then
            log_message "SUCCESS" "Process '$process_name' terminated successfully with $signal"
            return 0
        fi
    done

    # If we get here, all signals failed
    log_message "ERROR" "Failed to kill '$process_name' after trying all signals"
    return 1
}

# Show usage information
show_usage() {
    cat << EOF
Usage: $(basename "$0") <process_name_1> [process_name_2] ...
Kills specified processes using escalating signals (SIGTERM -> SIGINT -> SIGKILL)

Arguments:
    process_name_N    Name of the process to kill

Example:
    $(basename "$0") firefox chrome
EOF
}

# Main function
main() {
    local exit_status=0

	# Check if at least one argument is provided
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi
    
    log_message "INFO" "SCRIPT_PID: $SCRIPT_PID"
    notify-send -i dialog-error \
        --hint=string:x-canonical-private-synchronous: \
        "Starting process termination"
    
    # Process each argument. If one fails, set exit_status to 1 and stop the script.
    for process in "$@"; do
        if ! kill_process "$process"; then
            exit_status=1
        fi
    done

    # Notify completion
    notify-send -i emblem-default \
        --hint=string:x-canonical-private-synchronous: \
        "Process termination complete"

    return $exit_status
}

# Execute main function with all arguments
main "$@"
exit $?
