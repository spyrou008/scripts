#!/bin/bash

# v0.1 - init
# v0.2 - distinction between PC and the Stadia controller

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

sleep 20 	## Default: 20. Time in sec to wait to ensure everything is loaded, otherwise the notifications might not work...

str_charging="charging"			# string to identify the battery is charging
str_pending_charge="pending-charge"	# string to identify the battery is charging

battery_high=81		# Default: 81. Value of high battery level, when charging. Value used to remind the cable is to be removed
battery_low=39		# Default: 39. Value of low battery level, when discharging. Value used to remind the cable is to be plugged in
battery_vlow=21		# Default: 21. Value of very low battery level

battery_low_icon=/usr/share/icons/hicolor/scalable/apps/xfce4-battery-critical.svg
battery_high_icon=/usr/share/icons/hicolor/scalable/apps/xfce4-battery-full-charging.svg

while true
do

	# -----------------------> LAPTOP Battery <-----------------------
	# export DISPLAY=:0.0
	# I do not want to install ACPI
	# battery_level=`acpi -b | grep -P -o '[0-9]+(?=%)'`
	# In Ubuntu UPOWER is installed by default
	pcbat_battery_percentage=`upower -e | grep 'BAT' | xargs upower -i | grep percentage | grep -P -o '[0-9]+(?=%)'`
	pcbat_battery_state=`upower -e | grep 'BAT' | xargs upower -i | grep state | awk -v OFS='\t' '{print $2}'`

	# echo battery percentage is : $pcbat_battery_percentage
	# echo battery state is : $pcbat_battery_state

	## Some values:
	#    state:               discharging
	#    state:               charging
	#    state:               pending-charge	# i.e. Using the Power source to function, so battery is idle
	#    percentage:          71%

	if [ $pcbat_battery_state = $str_charging ] || [ $pcbat_battery_state = $str_pending_charge ] ; then # if charging OR pending charge

		# echo Yes Battery charging !!!
		if [ $pcbat_battery_percentage -ge $battery_high ]; then
			notify-send --icon=$battery_high_icon "Battery Full" "Level: ${pcbat_battery_percentage}% "
			paplay /usr/share/sounds/freedesktop/stereo/dialog-information.oga
		fi
	else
		# echo Nope Battery is not charging, i.e. discharging or pending-charge !!!!
		if [ $pcbat_battery_percentage -le $battery_vlow ]; then
			notify-send --icon=$battery_low_icon "Battery Very Low" "Level: ${pcbat_battery_percentage}%"
			paplay /usr/share/sounds/freedesktop/stereo/suspend-error.oga
		elif [ $pcbat_battery_percentage -le $battery_low ]; then
			notify-send --icon=$battery_low_icon "Battery Low" "Level: ${pcbat_battery_percentage}%"
			paplay /usr/share/sounds/freedesktop/stereo/dialog-information.oga
		fi
	fi


	# -----------------------> Stadia gaming controller Battery <-----------------------
	# for Stadia gaming controller over Bluetooth
	stadia_battery_percentage=`upower -e | grep 'gaming_input_dev_E4_' | xargs upower -i | grep percentage | grep -P -o '[0-9]+(?=%)'`
	if ! [ -z "$stadia_battery_percentage" ]; then 	# If controller is found over Bluetooth (i.e. the variable is NOT empty)
		# Controller on Bluetooth. State is always discharging over Bluetooth.
		# echo stadia battery percentage is : $stadia_battery_percentage
		if [ $stadia_battery_percentage -le $battery_vlow ]; then
			notify-send --icon=$battery_low_icon "Stadia Controller Battery Very Low" "Level: ${stadia_battery_percentage}%"
			paplay /usr/share/sounds/freedesktop/stereo/suspend-error.oga
		elif [ $stadia_battery_percentage -le $battery_low ]; then
			notify-send --icon=$battery_low_icon "Stadia Controller Battery Low" "Level: ${stadia_battery_percentage}%"
			paplay /usr/share/sounds/freedesktop/stereo/dialog-information.oga
		fi
	# else	# If controller NOT found over Bluetooth (i.e. the variable is empty)
		# echo Stadia Controller NOT found over Bluetooth
	fi

	# echo ""
	sleep 180	# Default: 180. Time in sec to wait before next check and optional notif & sound
done

# change 2 sleep <----------------------- <----------------------- <----------------------- <-----------------------
# Check battery_high , battery_low , battery_vlow <----------------------- <----------------------- <---------------
# Check les echo a mettre en commentaire ou pas <----------------------- <----------------------- <-----------------
