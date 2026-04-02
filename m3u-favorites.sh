#!/bin/bash
##!/usr/bin/bash

# Execute me : 
# 	bash ~/github/scripts/m3u-favorites.sh <input.m3u>

# v.0.1 ChatGPT initial version

# Purpose: Here's a Bash script that
#    Takes an M3U file as input.
#    Verifies that the file exists and starts with #EXTM3U.
#    Reorders entries based on a prioritized list of keywords found in #EXTINF lines. 
#    The script shall support case-insensitive matching
#    The script shall strip double quotes from the #EXTINF line before doing keyword matching — but keep the original line intact when writing to the output.
#    The script shall support additional lines like #EXTVLCOPT, #EXTGRP, or other tags between #EXTINF and the URL, breaking the strict assumption of one #EXTINF followed immediately by a URL.
#    Outputs a new M3U file.

# Check input arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 input_file.m3u output_file.m3u"
    exit 1
fi

input_file="$1"
output_file="$2"
##output_file="~/Downloads/uk2.m3u"


# Check file existence
if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' does not exist."
    exit 2
fi

# Check if the file starts with #EXTM3U
if ! grep -q '^#EXTM3U' "$input_file"; then
    echo "Error: File does not start with #EXTM3U"
    exit 3
fi

# Define keyword priorities (highest priority first)
# keywords=("News" "Sports" "Movies" "Music" "Kids")

keywords=("CBeebies.uk" "CBBC.uk" "DisneyJunior.us@East" "DisneyXD.us@West" "LegoChannel.us" "Nicktoons.us" "PBSKids.us" "PBSKidsAlaska.us" "TinyPop.uk" "TortuesNinjaTV.us@Canada" "TortuesNinjaTV.us@France" "TotallyTurtles.us" "TotallyTurtles.us@Canada" "JapanimTV.be") 
# Kids with tvg-id

keywords=("BBC One Wales" "BBC Two HD" "BBC Two Wales" "BBC World News" "Bloomberg TV Europe" "Bloomberg TV EMEA" "NBC News" "BBC Parliament" "CBeebies" "Kids" "Beano TV" "Pop" "Blaze" "DiscoverFilm" "GREAT!" "Revry" "Z Nation" "MTV Live" "TalkTV" "TOP Barca" "Trace Hits" "V2BEAT" "BBC Four" "BBC RB 1" "S4C" "MUTV" "Hard Knocks Fighting" "Horse and Country" "Strongman" "TNA Wrestling" "World Billiards" "World of Freesports" "People Are Awesome" "Inside Crime" "MBC" "Mystery TV" "TBN UK" "KTO" "Duck Dynasty" "Now 70" "Now 80" "NOW Rock") 
# UK

keywords=("BBC America" "BBC News" "E! East" "Disney Channel" "Disney Junior" "Lego Channel" "Nick Jr" "PBS Kids" "Kids" "Bloomberg" "ESPN U" "ESPNews") 
# USA

keywords=("BFM Business" "BFM Tech" "BFM TV" "LCI" "CNews" "Bloomberg TV Europe" "Bloomberg TV EMEA" "France 2" "France 5" "RMC Découverte" "RMC Story" "Arte" "TF1" "TFX") 
# FR




# Temporary workspace
temp_dir=$(mktemp -d)
declare -A keyword_files

# Create a temp file for each keyword
for keyword in "${keywords[@]}"; do
    keyword_files["$keyword"]="$temp_dir/$keyword.m3u"
    > "${keyword_files[$keyword]}"
done

# File for unmatched entries
other_file="$temp_dir/Other.m3u"
> "$other_file"

# Output file header
echo "#EXTM3U" > "$output_file"

# Process entries as blocks (starting at each #EXTINF)
current_block=""
current_extinf=""
while IFS= read -r line; do
    if [[ "$line" == "#EXTM3U" ]]; then
        continue  # skip header already written
    elif [[ "$line" == "#EXTINF"* ]]; then
        # New entry block starts
        if [[ -n "$current_block" ]]; then
            # Categorize previous block
            cleaned_extinf=$(echo "$current_extinf" | tr -d '"' | tr '[:upper:]' '[:lower:]')
            matched=false
            for keyword in "${keywords[@]}"; do
                lower_keyword=$(echo "$keyword" | tr '[:upper:]' '[:lower:]')
                if [[ "$cleaned_extinf" == *"$lower_keyword"* ]]; then
                    echo -e "$current_block" >> "${keyword_files[$keyword]}"
                    matched=true
                    break
                fi
            done
            if [ "$matched" = false ]; then
                echo -e "$current_block" >> "$other_file"
            fi
        fi
        # Start new block
        current_block="$line"$'\n'
        current_extinf="$line"
    else
        # Add to current block
        current_block+="$line"$'\n'
    fi
done < "$input_file"

# Handle last block
if [[ -n "$current_block" ]]; then
    cleaned_extinf=$(echo "$current_extinf" | tr -d '"' | tr '[:upper:]' '[:lower:]')
    matched=false
    for keyword in "${keywords[@]}"; do
        lower_keyword=$(echo "$keyword" | tr '[:upper:]' '[:lower:]')
        if [[ "$cleaned_extinf" == *"$lower_keyword"* ]]; then
            echo -e "$current_block" >> "${keyword_files[$keyword]}"
            matched=true
            break
        fi
    done
    if [ "$matched" = false ]; then
        echo -e "$current_block" >> "$other_file"
    fi
fi

# Append all categorized blocks to output
for keyword in "${keywords[@]}"; do
    cat "${keyword_files[$keyword]}" >> "$output_file"
done
cat "$other_file" >> "$output_file"

# Cleanup
rm -r "$temp_dir"

# echo "Sorted M3U file created at '$output_file'"
# cat "$output_file"

