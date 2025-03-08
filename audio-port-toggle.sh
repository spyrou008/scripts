#!/bin/bash

# Execute me : 
# 	bash ~/github/scripts/audio-port-toggle.sh
# in `xfce4-keyboard-settings` > App shortcut > and map the above command with `Super + H`

# v.0.1 ChatGPT initial version
# v.0.2 tweak the toggle to my audio needs. file in /tmp/ . Add pactl commands and notification. 
# v.0.3 switch from SINK ID to SINK NAME. to prevent batch to fail with or without the docking station. SINK ID changes , but not the SINK NAME
# v.0.4 All the current applications moved to the new output device. Plus add a check if the headphones are connected or not. 
# v.0.5 Modified check if the headphones are connected or not. 
# v.0.6 Clean code with Cursor - AI Code Editor

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


# Define constants for better maintainability
# SINK ID can change if dock station is on or off. so below NAME is given by either `pactl get-default-sink` OR `pactl list short sinks`
readonly SINK_NAME="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic"
# Card ID can change if dock station is on or off. so below NAME is given by `pactl list cards`
readonly CARD_NAME="alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic"
# persistent setting until reboot
readonly TOGGLE_FILE="/tmp/toggleSinkPort.tmp"
# Define a variable to toggle between Speaker and Headphones. default value is Speaker.
readonly DEFAULT_PORT="Speaker"
readonly DEFAULT_VOLUME="10%"
readonly LOG_FILE="/tmp/audio-toggle.log"

# Helper function for logging
log_message() {
    local level=$1
    local message=$2
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" | tee -a "$LOG_FILE"
}


# Helper function to check if headphones are connected
check_headphones() {
    # Toggle port and handle the switch
    # TODO: The toggle logic assumes only two ports (Speaker and Headphones) exist, which may not always be true. This can lead to unexpected behavior when other audio output ports are present.
    # TODO: The headphone availability check is fundamentally flawed, as it uses a fixed profile suffix that always passes, even when headphones are not actually connected.
    #	test if this specific card has headphones not available. to make better as a good output looks like : (card 1)
    #			[Out] Headphones: Headphones (type: Headphones, priority: 200, latency offset: 0 usec, availability group: Headphone Mic, available)
    #	and a bad output looks like : (card 0)
    #			[Out] Headphones: Headphones (type: Headphones, priority: 100, latency offset: 0 usec, not available)
    if pactl list cards | grep -A 60 "$CARD_NAME" | grep -q "\[Out\] Headphones: .* not available"; then
        notify-send -i dialog-error "ERROR: Headphones MAY NOT be connected on card: $CARD_NAME"
        log_message "ERROR" "Headphones MAY NOT be connected on card: $CARD_NAME"
        return 1
    fi
    return 0
}

# Helper function to move all audio streams to new sink
move_audio_streams() {
    local sink_name=$1
    local sink_inputs
    
    # Now we need to take care of all the current applications that may have lost the sound during the switch. List all the running sink input streams (applications) , get their ID and remove the # character
    sink_inputs=$(pactl list sink-inputs | grep 'Sink Input #' | awk '{print $3}' | sed 's/#//')
    # Loop through all the running sink input streams (applications) , get their ID and remove the # character. Move them to the desired sink (output device)
    for index in $sink_inputs; do
        if ! pactl move-sink-input "$index" "$sink_name"; then
            log_message "WARNING" "Failed to move sink input $index to $sink_name"
        fi
    done
}

# Helper function to switch audio output
switch_audio() {
    local new_port=$1
    # Get the sink name you want to move the sink inputs to. The list of available sinks (output devices) is given by : 
	#  pactl list sinks | grep "Name:"
    # TODO: Critical issue with audio device configuration: It incorrectly constructs sink names by naively appending port names to a base sink name, which fails because sink name formats are not consistent across different ports.
    # List all sinks and find the one matching our card that has the specified port
    #  pactl list sinks | grep -B1 "Name: $SINK_NAME" | grep "Name:" | head -n1 | cut -d' ' -f2
    # Hardcoding the sink name for now.
    local sink_name="${SINK_NAME}.HiFi__${new_port}__sink"    
    local profile
    # echo "switch_audio: $new_port"

    # Get the current available profiles
    #  profile=$(pactl list cards | grep -A20 "Name: $CARD_NAME" | grep "HiFi.*$port" | head -n1 | awk '{print $1}')
    # Hardcoding the profile for now.
    # Set profile suffix based on port
    # TODO: Critical issue with audio device configuration: hardcoded profile names for Speaker and Headphones that may not match the actual profiles reported by the system, potentially causing profile setting failures.
    if [[ $new_port == "Speaker" ]]; then
        profile="HiFi (HDMI1, HDMI2, HDMI3, Headset, Mic1, Speaker)"
    else
        profile="HiFi (HDMI1, HDMI2, HDMI3, Headphones, Headset, Mic1)"
    fi
    log_message "INFO" "Switching to port: $new_port , with sink: $sink_name"
    
    # Configure audio device
    # Set card profile and sink port
    # Set the specified card profile (identified by its symbolic name).
    if ! pactl set-card-profile "$CARD_NAME" "$profile"; then
        log_message "ERROR" "Failed to set card profile"
        notify-send -i dialog-error "Error" "Failed to set card profile"
        return 1
    fi
    
    # Set the specified source to the specified  port (identified by its symbolic name).
    if ! pactl set-sink-port "$sink_name" "[Out] ${new_port}"; then
        log_message "ERROR" "Failed to set sink port"
        notify-send -i dialog-error "Error" "Failed to set sink port"
        return 1
    fi

    # Configure sink settings
    # Set the mute status of the specified sink: Remove the mute , just in case, for the switch.
    pactl set-sink-mute "$sink_name" "0"
    # Set  the volume of the specified sink. VOLUME can be specified as a percentage: Low volume , just in case, for the switch.
    pactl set-sink-volume "$sink_name" "$DEFAULT_VOLUME"
    # Change the default output device :
    pacmd set-default-sink "$sink_name"
    
    # Move existing audio streams (all current applications) to new sink
    move_audio_streams "$sink_name"
    
    # Update toggle file and notify user
    echo "$new_port" > "$TOGGLE_FILE"
    notify-send -i notification-audio-volume-high "Audio output switched to: $new_port"
    log_message "INFO" "Successfully switched audio output to $new_port"
}

main() {
    # Create log file if it doesn't exist
    touch "$LOG_FILE"
    log_message "INFO" "Starting audio port toggle script"

    # Initialize toggle file if it doesn't exist
    if [[ ! -f $TOGGLE_FILE ]]; then
        echo "$DEFAULT_PORT" > "$TOGGLE_FILE"
    fi

    # Read current port from file
    local current_port
    current_port=$(<"$TOGGLE_FILE")

    # Toggle port and handle the switch
    if [[ $current_port == "$DEFAULT_PORT" ]]; then
        # Check if headphones are available before switching
        if ! check_headphones; then
            switch_audio $DEFAULT_PORT
            exit 1
        fi
        switch_audio "Headphones"
    else
        switch_audio $DEFAULT_PORT
    fi
}

# Execute main function
main
exit 0



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

