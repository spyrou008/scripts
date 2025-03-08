#!/bin/bash

# v0.1 - init
# v0.2 - distinction between PC and the Stadia controller
# v0.3 - Improved error handling, configurability, and code organization. with Cursor - AI Code Editor

## To make this script better : 
## https://bbs.archlinux.org/viewtopic.php?pid=1431917

## Script that will look at the battery level on a regular basis
##  and provide a notification + sound if there is something to do.

## To make this execuatable
##  chmod +x ./battery-alert.sh 

## To launch the script after logging in, a solution is:
##  For a specific user, To add the script to the bottom of the user profile file: ~/.profile
##  For system-wide users, To add the script on the /etc/profile file. 
##  Like this: 
##  $ cp /home/$USER/github/scripts/battery-alert.sh /opt/my_scripts/battery-alert.sh
##  $ mousepad ~/.profile
##   sh /opt/my_scripts/battery-alert.sh &
##    OR:
##   sh /home/$USER/github/scripts/battery-alert.sh &
## Script works on : Ubuntu 20.04 LTS + Manjaro-xfce-20.0.1

###################
# Configuration
###################

# Battery level thresholds
readonly BATTERY_HIGH=81		# Default: 81. Value of high battery level, when charging. Value used to remind the cable is to be removed. Notify when charging reaches this level
readonly BATTERY_LOW=39			# Default: 39. Value of low battery level, when discharging. Value used to remind the cable is to be plugged in. First warning when discharging
readonly BATTERY_CRITICAL=21	# Default: 21. Value of very low battery level. Urgent warning when discharging

# Notification icons
readonly ICON_LOW="/usr/share/icons/hicolor/scalable/apps/xfce4-battery-critical.svg"
readonly ICON_HIGH="/usr/share/icons/hicolor/scalable/apps/xfce4-battery-full-charging.svg"

# Sound files
readonly SOUND_NORMAL="/usr/share/sounds/freedesktop/stereo/dialog-information.oga"
readonly SOUND_CRITICAL="/usr/share/sounds/freedesktop/stereo/suspend-error.oga"

# Check interval (in seconds)
readonly CHECK_INTERVAL=180	## Default: 180. Time in sec to wait between checks
readonly STARTUP_DELAY=20	## Default: 20. Time in sec to wait to ensure everything is loaded, otherwise the notifications might not work...

###################
# Helper Functions
###################

notify() {
    local title="$1"
    local message="$2"
    local icon="$3"
    local sound="$4"

	    # Show notification and play sound
    if ! notify-send --icon="$icon" "$title" "$message"; then
        echo "ERROR: Failed to send notification: $title - $message"
    fi
    
    if ! paplay "$sound" 2>/dev/null; then
        echo "ERROR: Failed to play sound: $sound"
    fi
}

get_battery_info() {
    local device="$1"
    local info
	# -----------------------> LAPTOP Battery <-----------------------
	# export DISPLAY=:0.0
	# I do not want to install ACPI
	# battery_level=`acpi -b | grep -P -o '[0-9]+(?=%)'`
	# In Ubuntu UPOWER is installed by default

    info=$(upower -e | grep "$device" | xargs upower -i 2>/dev/null)
    if [ -n "$info" ]; then
        echo "$info"
    else
        echo "DEBUG: No battery info found for device: $device"
    fi
}

get_battery_percentage() {
    local info="$1"
    local percentage
    percentage=$(echo "$info" | grep percentage | grep -P -o '[0-9]+(?=%)')
    echo "${percentage:-0}"  # Return 0 if no percentage found
    # echo "$info" | grep percentage | grep -P -o '[0-9]+(?=%)'
}

get_battery_state() {
    local info="$1"
    local state
    state=$(echo "$info" | grep state | awk '{print $2}')
    echo "${state:-unknown}"  # Return 'unknown' if no state found
    # echo "$info" | grep state | awk '{print $2}'
}

check_laptop_battery() {
    local battery_info
    battery_info=$(get_battery_info "BAT")
    
	echo "INFO: Laptop battery info: $battery_info"
    if [ -z "$battery_info" ]; then
        echo "DEBUG: No laptop battery found"
        return
    fi

    local percentage
    percentage=$(get_battery_percentage "$battery_info")
    local state
    state=$(get_battery_state "$battery_info")

    # echo "INFO: Laptop battery percentage: $percentage"
    # echo "INFO: Laptop battery state: $state"

	## Some values:
	#    state:               discharging
	#    state:               charging
	#    state:               pending-charge	# i.e. Using the Power source to function, so battery is idle
	#    percentage:          71%

    case "$state" in
		# if charging OR pending charge OR fully charged
        "charging"|"pending-charge"|"fully-charged") 	
            if [ "$percentage" -ge "$BATTERY_HIGH" ]; then
                notify "Battery Full" "Level: ${percentage}%" "$ICON_HIGH" "$SOUND_NORMAL"
				# echo "INFO: Battery Full" "Level: ${percentage}% "
				
            fi
            ;;
        "discharging")
            if [ "$percentage" -le "$BATTERY_CRITICAL" ]; then
                notify "Battery Very Low" "Level: ${percentage}%" "$ICON_LOW" "$SOUND_CRITICAL"
            elif [ "$percentage" -le "$BATTERY_LOW" ]; then
                notify "Battery Low" "Level: ${percentage}%" "$ICON_LOW" "$SOUND_NORMAL"
            fi
            ;;
    esac
}

check_stadia_controller() {
	# -----------------------> Stadia gaming controller Battery <-----------------------
	# for Stadia gaming controller over Bluetooth
    local controller_info
    controller_info=$(get_battery_info "gaming_input_dev_E4_")
    
    if [ -z "$controller_info" ]; then
        echo "DEBUG: No Stadia controller battery found"
        return
    fi

	# If controller is found over Bluetooth (i.e. the variable is NOT empty)
	# Controller on Bluetooth. State is always discharging over Bluetooth.
	# echo stadia battery percentage is : $stadia_battery_percentage

    local percentage
    percentage=$(get_battery_percentage "$controller_info")

	echo "INFO: Stadia controller battery percentage: $percentage"

    if [ "$percentage" -le "$BATTERY_CRITICAL" ]; then
        notify "Stadia Controller Battery Very Low" "Level: ${percentage}%" "$ICON_LOW" "$SOUND_CRITICAL"
    elif [ "$percentage" -le "$BATTERY_LOW" ]; then
        notify "Stadia Controller Battery Low" "Level: ${percentage}%" "$ICON_LOW" "$SOUND_NORMAL"
    fi
}

###################
# Main Script
###################

echo "INFO: Battery alert script starting"

# Ensure notifications work by waiting for desktop environment
sleep "$STARTUP_DELAY"

# Main loop
while true; do
    check_laptop_battery
#    check_stadia_controller
    sleep "$CHECK_INTERVAL"
done

# change 2 sleep <----------------------- <----------------------- <----------------------- <-----------------------
# Check battery_high , battery_low , battery_vlow <----------------------- <----------------------- <---------------
# Check les echo a mettre en commentaire ou pas <----------------------- <----------------------- <-----------------
