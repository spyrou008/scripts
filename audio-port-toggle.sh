#!/bin/bash

# Execute me : 
# 	bash ~/github/scripts/audio-port-toggle.sh
# in `xfce4-keyboard-settings` > App shortcut > and map the above command with `Super + H`

# v.0.1 ChatGPT initial version
# v.0.2 tweak the toggle to my audio needs. file in /tmp/ . Add pactl commands and notification. 
# v.0.3 switch from SINK ID to SINK NAME. to prevent batch to fail with or without the docking station. SINK ID changes , but not the SINK NAME
# v.0.4 All the current applications moved to the new output device. Plus add a check if the headphones are connected or not. 


# FYI: this script is just a shortcut for the following command line , which controls `pavucontrol` > Tab "Output Devices"
#  $ pactl set-sink-port SINK PORT
# where SINK is given by the commands :
#  $ pactl get-default-sink
#  $ pactl list short sinks
# where PORT is given by the commands : (look for "Active Port:")
#  $ pactl list sinks
# FYI: this script is just a shortcut for the following command line , which controls `pavucontrol` > Tab "Configuration"
#  $ pactl set-card-profile <card_name> <profile_name> 
# where <card_name> & <profile_name> are given by the command : `pactl list cards`


# Define a variable to toggle between Speaker and Headphones. default value is Speaker.
toggleSinkPort="Speaker"
fileSinkPort=/tmp/toggleSinkPort.tmp
# Card ID can change if dock station is on or off. so below NAME is given by `pactl list cards`
myCardName="alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic" 
# SINK ID can change if dock station is on or off. so below NAME is given by either `pactl get-default-sink` OR `pactl list short sinks`
mySinkToToggle="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink"

# Check if the toggle file exists, and if not, create it with the default value
if [[ ! -f $fileSinkPort ]]; then
    echo "$toggleSinkPort" > $fileSinkPort
fi

# Read the current value from the toggle file
toggleSinkPort=$(<$fileSinkPort)

# Toggle the value
if [[ $toggleSinkPort == "Speaker" ]]; then
	toggleSinkPort="Headphones"

	if pactl list cards | grep -q "\[Out\] Headphones: .* not available"; then
		echo "Headphones are NOT connected."

	else
		echo "Headphones are connected."

		# Get the sink name you want to move the sink inputs to. The list of available sinks (output devices) is given by : 
		#  pactl list sinks | grep "Name:"
		sink_name="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Headphones__sink"

		# Set the specified card profile (identified by its symbolic name).
		# pactl set-card-profile $myCardName "HiFi (HDMI1, HDMI2, HDMI3, Headphones, Headset, Mic1)"
		pactl set-card-profile alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic "HiFi (HDMI1, HDMI2, HDMI3, Headphones, Headset, Mic1)"
		# Set the specified source to the specified  port (identified by its symbolic name).
		# pactl set-sink-port $mySinkToToggle "[Out] Headphones"
		pactl set-sink-port "$sink_name" "[Out] Headphones"


		# Set the mute status of the specified sink: Remove the mute , just in case, for the switch.
		pactl set-sink-mute "$sink_name" "0"
		# Set  the volume of the specified sink. VOLUME can be specified as a percentage: Low volume , just in case, for the switch.
		pactl set-sink-volume "$sink_name" "10%"

		# Change the default output device :
		pacmd set-default-sink "$sink_name"

		# Now we need to take care of all the current applications that may have lost the sound during the switch. List all the running sink input streams (applications) , get their ID and remove the # character
		sink_inputs=$(pactl list sink-inputs | grep 'Sink Input #' | awk '{print $3}' | sed 's/#//')
		# Move each sink input (application) to the desired sink (output device)
		for index in $sink_inputs; do
		    pactl move-sink-input "$index" "$sink_name"
		done

	fi

else
	toggleSinkPort="Speaker"

	# Get the sink name you want to move the sink inputs to. The list of available sinks (output devices) is given by : 
	#  pactl list sinks | grep "Name:"
	sink_name="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink"

	# Set the specified card profile (identified by its symbolic name).
	# pactl set-card-profile $myCardName "HiFi (HDMI1, HDMI2, HDMI3, Headset, Mic1, Speaker)"
	pactl set-card-profile alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic "HiFi (HDMI1, HDMI2, HDMI3, Headset, Mic1, Speaker)"
	# Set the specified source to the specified  port (identified by its symbolic name).
	# pactl set-sink-port $mySinkToToggle "[Out] Speaker"
	pactl set-sink-port "$sink_name" "[Out] Speaker"


	# Set the mute status of the specified sink: Remove the mute , just in case, for the switch.
	pactl set-sink-mute "$sink_name" "0"
	# Set  the volume of the specified sink. VOLUME can be specified as a percentage: Low volume , just in case, for the switch.
	pactl set-sink-volume "$sink_name" "10%"

	# Change the default output device :
	pacmd set-default-sink "$sink_name"

	# Now we need to take care of all the current applications that may have lost the sound during the switch. List all the running sink input streams (applications) , get their ID and remove the # character
	sink_inputs=$(pactl list sink-inputs | grep 'Sink Input #' | awk '{print $3}' | sed 's/#//')
	# Move each sink input (application) to the desired sink (output device)
	for index in $sink_inputs; do
	    pactl move-sink-input "$index" "$sink_name"
	done

fi


# Write the updated value back to the toggle file
echo "$toggleSinkPort" > $fileSinkPort

# Print the current value
echo "toggleSinkPort is now: $toggleSinkPort"
notify-send -i notification-audio-volume-high --hint=string:x-canonical-private-synchronous: "Audio is now on: $toggleSinkPort"

exit



# --------------------------------------------------------------------------------------------------------------------------------------------

TV LG on the right hand side with Small round Dock Dell
$ pactl list short sinks
0	alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp_5__sink	module-alsa-card.c	s16le 2ch 48000Hz	IDLE
1	alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp_4__sink	module-alsa-card.c	s16le 2ch 48000Hz	IDLE
2	alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp_3__sink	module-alsa-card.c	s16le 2ch 48000Hz	RUNNING
3	alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink	module-alsa-card.c	s16le 2ch 48000Hz	IDLE

Computer:
$ pactl list short sinks
0	alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp_5__sink	module-alsa-card.c	s16le 2ch 48000Hz	IDLE
1	alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp_4__sink	module-alsa-card.c	s16le 2ch 48000Hz	IDLE
2	alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp_3__sink	module-alsa-card.c	s16le 2ch 48000Hz	IDLE
3	alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink	module-alsa-card.c	s16le 2ch 48000Hz	RUNNING



# --------------------------------------------------------------------------------------------------------------------------------------------

After change: in your `/etc/pulse/default.pa` file to have it across reboots.
# K Modif: My default values are: Speakers , Unmute, low volume (6553=10%). Config tested with `pulseaudio -nC`. 
# Info , do not put "" , even if this seem odd. 
set-default-sink alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink
set-sink-port alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink [Out] Speaker
set-sink-mute alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink 0
set-sink-volume alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink 6553


# --------------------------------------------------------------------------------------------------------------------------------------------
# my commands:
pactl set-sink-port "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink" "[Out] Headphones"
pactl set-sink-port "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink" "[Out] Speaker"

set-sink-volume "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink" VOLUME

# Source:
# https://ubuntuforums.org/showthread.php?t=1370383
# https://unix.stackexchange.com/questions/175930/change-default-port-for-pulseaudio-line-out-not-headphones

# v.0.1 Credit to tsvetan for creating the initial script and posting instructions on how to easily switch audio device!
# v.0.1 Credit to yanber for new version

declare -i sinks=(`pacmd list-sinks | sed -n -e 's/\**[[:space:]]index:[[:space:]]\([[:digit:]]\)/\1/p'`)
declare -i sinks_count=${#sinks[*]}
declare -i active_sink_index=`pacmd list-sinks | sed -n -e 's/\*[[:space:]]index:[[:space:]]\([[:digit:]]\)/\1/p'`
declare -i next_sink_index=${sinks[0]}

#find the next sink (not always the next index number)
echo 1. Find the next sink
declare -i ord=0
while [ $ord -lt $sinks_count ];
do
    echo ${sinks[$ord]}
    if [ ${sinks[$ord]} -gt $active_sink_index ] ; then
        next_sink_index=${sinks[$ord]}
        echo next_sink_index: ${next_sink_index}
        break
    fi
    let ord++
done
echo Final next_sink_index: ${next_sink_index}


echo Force next_sink_index: 5
next_sink_index=5

#change the default sink
# pacmd "set-default-sink ${next_sink_index}"
# echo 2. Change the default sink
# echo pacmd "set-default-sink ${next_sink_index}"

#change the default sink AND port
echo 2. Change the default sink AND port
pactl set-sink-port "5" "[Out] Speaker"
# pactl set-sink-port "5" "[Out] Headphones"

#move all inputs to the new sink
echo 3. Move all inputs to the new sink
for app in $(pacmd list-sink-inputs | sed -n -e 's/index:[[:space:]]\([[:digit:]]\)/\1/p');
do
    pacmd "move-sink-input $app $next_sink_index"
    echo pacmd "move-sink-input $app $next_sink_index"
done

#display notification
declare -i ndx=0
pacmd list-sinks | sed -n -e 's/device.description[[:space:]]=[[:space:]]"\(.*\)"/\1/p' | while read line;
do
    if [ $(( $ord % $sinks_count )) -eq $ndx ] ; then
        notify-send -i notification-audio-volume-high --hint=string:x-canonical-private-synchronous: "Sound output switched to" "$line"
        exit
    fi
    let ndx++
done;

exit



# Work in progress below ...
I want to switch to the next output profile  (port) which not muted. 
either do a toggle, or go to the next. Note , the next one can be the current one. (especially for sink)
easier : I want to toggle the port. 
get current port : then toggle. 
can''t get: so force the speaker at boot . and write the current (speaker) in a file. then toggle at will.


----
works : 
pacmd "set-default-sink 5"
how to identify this one ???
is it the right name ? to be hardcoded ?


pactl set-sink-port "5" "[Out] Speaker"
pactl set-sink-port "5" "[Out] Headphones"

If this works, you can put:
set-sink-port 0 analog-output-lineout
in your `/etc/pulse/default.pa` file to have it across reboots.


pactl set-sink-port "5" "[Out] Headphones"
pactl set-sink-port SINK PORT = Set  the  specified  sink  (identified  by  its symbolic name or numerical index) to the specified port (identified by its symbolic name).

pactl get-sink-mute 5

useful commands :
pactl set-sink-port "5" "[Out] Speaker"
pactl set-sink-port "5" "[Out] Headphones"
pactl list short sinks
pactl list sinks
status="$(cat /sys/class/drm/card0-eDP-1/status)"
pactl set-card-profile 0 output:analog-stereo+input:analog-stereo
pactl set-card-profile 0 output:hdmi-stereo+input:analog-stereo



bof commands :
pacmd list-sources
pacmd list-sources | sed -n -e 's/\*[[:space:]]index:[[:space:]]\([[:digit:]]\)/\1/p'
pacmd list
pacmd list | grep "active port"
pacmd list-sinks | sed -n -e 's/device.description[[:space:]]=[[:space:]]"\(.*\)"/\1/p' 
pacmd list-cards | grep "active profile: " | cut -d" " -f3

