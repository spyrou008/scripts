#!/bin/bash

# Execute me : 
# 	bash /home/chris/github/scripts/audio-port-toggle.sh
# in `xfce4-keyboard-settings` > App shortcut > and map the above command with `Super + H`

# v.0.1 ChatGPT initial version
# v.0.2 tweak the toggle to my audio needs. file in /tmp/ . Add pactl commands and notification. 
# v.0.3 switch from SINK ID to SINK NAME. to prevent batch to fail with or without the docking station. SINK ID changes , but not the SINK NAME

# Define a variable to toggle between Speaker and Headphones. default value is Speaker.
toggleSinkPort="Speaker"
fileSinkPort=/tmp/toggleSinkPort.tmp
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
	# Set the specified source to the specified  port (identified by its symbolic name).
	pactl set-sink-port $mySinkToToggle "[Out] Headphones"
else
	toggleSinkPort="Speaker"
	# Set the specified source to the specified  port (identified by its symbolic name).
	pactl set-sink-port $mySinkToToggle "[Out] Speaker"
fi

# Set the mute status of the specified sink: Remove the mute , just in case, for the switch.
pactl set-sink-mute $mySinkToToggle "0"
# Set  the volume of the specified sink. VOLUME can be specified as a percentage: Low volume , just in case, for the switch.
pactl set-sink-volume $mySinkToToggle "10%"

# Write the updated value back to the toggle file
echo "$toggleSinkPort" > $fileSinkPort

# Print the current value
echo "toggleSinkPort is now: $toggleSinkPort"
notify-send -i notification-audio-volume-high --hint=string:x-canonical-private-synchronous: "Audio is now on: $toggleSinkPort"


exit


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

