#!/bin/bash

## To make this script better : 
## https://bbs.archlinux.org/viewtopic.php?pid=1431917

## Script that will look at the battery level on a regular basis
## and provide a notification + sound if there is something to do.

## To launch the script , it may be needed to do:
##  chmod +x
## To launch the script after logging in, a solution is:
##  For a specific user, To add the script to the bottom of the user profile file: ~/.profile
##  For system-wide users, To add the script on the /etc/profile file. 
##  Like this: 
##  $ cp /home/chris/github/scripts/battery-alert.sh /opt/my_scripts/battery-alert.sh
##  $ mousepad ~/.profile
##   sh /opt/my_scripts/battery-alert.sh &
##    OR:
##   sh /home/chris/github/scripts/battery-alert.sh &
## Script works on : Ubuntu 20.04 LTS + Manjaro-xfce-21.0.7

## to ensure everything is loaded, otherwise the notifications might not work...
sleep 20

# string to identify the battery is charging
str_charging="charging"
# Value of high battery level, when charging. Value used to remind the cable is to be removed
battery_high=94
# Value of low battery level, when discharging. Value used to remind the cable is to be plugged in
battery_low=41
battery_vlow=21

battery_low_icon=/usr/share/icons/hicolor/scalable/apps/xfce4-battery-critical.svg
battery_high_icon=/usr/share/icons/hicolor/scalable/apps/xfce4-battery-full-charging.svg

while true
do
	# export DISPLAY=:0.0
	# I do not want to install ACPI
	# battery_level=`acpi -b | grep -P -o '[0-9]+(?=%)'`
	# In Ubuntu UPOWER is installed by default
	battery_percentage=`upower -e | grep 'BAT' | xargs upower -i | grep percentage | grep -P -o '[0-9]+(?=%)'`
	battery_state=`upower -e | grep 'BAT' | xargs upower -i | grep state | awk -v OFS='\t' '{print $2}'`

	# echo battery percentage is : $battery_percentage
	# echo $battery_percentage
	# echo battery state is : $battery_state
	# echo $battery_state

	## Some values:
	#    state:               discharging
	#    state:               charging
	#    percentage:          86%

	if [ $battery_state = $str_charging ]; then
		# echo Yes Battery charging !!!
		if [ $battery_percentage -ge $battery_high ]; then
			notify-send --icon=$battery_high_icon "Battery Full" "Level: ${battery_percentage}% "
			paplay /usr/share/sounds/freedesktop/stereo/dialog-information.oga
		fi

	else
		# echo Nope Battery is discharging !!!!
		if [ $battery_percentage -le $battery_vlow ]; then
			notify-send --icon=$battery_low_icon "Battery Low" "Level: ${battery_percentage}%"
			paplay /usr/share/sounds/freedesktop/stereo/suspend-error.oga
		elif [ $battery_percentage -le $battery_low ]; then
			notify-send --icon=$battery_low_icon "Battery Low" "Level: ${battery_percentage}%"
			paplay /usr/share/sounds/freedesktop/stereo/dialog-information.oga
		fi
	fi
	sleep 180
done
