#!/bin/bash
##!/usr/bin/bash

# Execute me : with either the game name , surrounded by double quotes if it has a space or special character/ 
# 	bash ~/github/scripts/find-game-nominations.sh "Game's Name"

# v.0.1 ChatGPT initial version + Cursor. 

# FYI: this script allows to search for the game name within a list of URL (copied locally or not). This allows to know if a game got awards or nominations. 
#  e.g.: "TUNIC" got many nominations. "Cinnabunny" got none. 


# Create a temporary directory for storing webpages
create_temporary_directory() {
    TMPDIR=$(mktemp -d)
    echo $TMPDIR
}
# Function to copy locally the webpages content. downloading the webpages locally will save bandwidth and also speed up repeated runs of your script.
copy_html_urls_locally() {
    # Loop through each URL # Download each URL and save to the temp folder
    for url in "${urls[@]}"; do
#    # Download page content and search for the term (case-insensitive)
#    if curl -s "$url" | grep -iqF "$search_term"; then
#        echo "- Match found in $url"
#    # else
#        # echo "No match in $url"
#    fi

        # Create a filename-safe version of the URL
        filename=$(echo "$url" | sed 's|https\?://||; s|/|_|g')
        
        # Download the page
        curl -s "$url" -o "$TMPDIR/$filename.html"
    done
}

# Check if input was provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 \"Attribute to search\""
    exit 1
fi
# Store the input attribute
search_term="$1"

# List of URLs to check (you can edit or replace this with a file input or argument list)
urls=(
    "https://en.wikipedia.org/wiki/D.I.C.E._Awards"
    "https://en.wikipedia.org/wiki/28th_Annual_D.I.C.E._Awards"
    "https://en.wikipedia.org/wiki/27th_Annual_D.I.C.E._Awards"
    "https://en.wikipedia.org/wiki/26th_Annual_D.I.C.E._Awards"
    "https://en.wikipedia.org/wiki/25th_Annual_D.I.C.E._Awards"
    "https://en.wikipedia.org/wiki/24th_Annual_D.I.C.E._Awards"
    "https://en.wikipedia.org/wiki/23rd_Annual_D.I.C.E._Awards"
    "https://en.wikipedia.org/wiki/22nd_Annual_D.I.C.E._Awards"
    "https://en.wikipedia.org/wiki/21st_Annual_D.I.C.E._Awards"
    "https://en.wikipedia.org/wiki/20th_Annual_D.I.C.E._Awards"
    "https://en.wikipedia.org/wiki/19th_Annual_D.I.C.E._Awards"
    "https://en.wikipedia.org/wiki/18th_Annual_D.I.C.E._Awards"
    "https://en.wikipedia.org/wiki/17th_Annual_D.I.C.E._Awards"
    "https://en.wikipedia.org/wiki/16th_Annual_D.I.C.E._Awards"
    "https://en.wikipedia.org/wiki/15th_Annual_Interactive_Achievement_Awards"
    "https://en.wikipedia.org/wiki/14th_Annual_Interactive_Achievement_Awards"
    "https://en.wikipedia.org/wiki/13th_Annual_Interactive_Achievement_Awards"
    "https://en.wikipedia.org/wiki/12th_Annual_Interactive_Achievement_Awards"
    "https://en.wikipedia.org/wiki/D.I.C.E._Award_for_Action_Game_of_the_Year"
    "https://en.wikipedia.org/wiki/D.I.C.E._Award_for_Adventure_Game_of_the_Year"
    "https://en.wikipedia.org/wiki/D.I.C.E._Award_for_Family_Game_of_the_Year"
    "https://en.wikipedia.org/wiki/D.I.C.E._Award_for_Racing_Game_of_the_Year"
    "https://en.wikipedia.org/wiki/D.I.C.E._Award_for_Fighting_Game_of_the_Year"
    "https://en.wikipedia.org/wiki/D.I.C.E._Award_for_Role-Playing_Game_of_the_Year"
    "https://en.wikipedia.org/wiki/D.I.C.E._Award_for_Sports_Game_of_the_Year"
    "https://en.wikipedia.org/wiki/D.I.C.E._Award_for_Strategy/Simulation_Game_of_the_Year"
    "https://en.wikipedia.org/wiki/D.I.C.E._Award_for_Outstanding_Achievement_for_an_Independent_Game"
    "https://en.wikipedia.org/wiki/D.I.C.E._Award_for_Game_of_the_Year"
    # Above pages from Source: https://en.wikipedia.org/wiki/D.I.C.E._Awards

    "https://en.wikipedia.org/wiki/British_Academy_Games_Awards"
    "https://en.wikipedia.org/wiki/21st_British_Academy_Games_Awards"
    "https://en.wikipedia.org/wiki/20th_British_Academy_Games_Awards"
    "https://en.wikipedia.org/wiki/19th_British_Academy_Games_Awards"
    "https://en.wikipedia.org/wiki/18th_British_Academy_Games_Awards"
    "https://en.wikipedia.org/wiki/17th_British_Academy_Games_Awards"
    "https://en.wikipedia.org/wiki/16th_British_Academy_Games_Awards"
    "https://en.wikipedia.org/wiki/15th_British_Academy_Games_Awards"
    "https://en.wikipedia.org/wiki/14th_British_Academy_Games_Awards"
    "https://en.wikipedia.org/wiki/13th_British_Academy_Games_Awards"
    "https://en.wikipedia.org/wiki/12th_British_Academy_Games_Awards"
    "https://en.wikipedia.org/wiki/11th_British_Academy_Games_Awards"
    "https://en.wikipedia.org/wiki/10th_British_Academy_Games_Awards"
    "https://en.wikipedia.org/wiki/9th_British_Academy_Games_Awards"
    "https://en.wikipedia.org/wiki/8th_British_Academy_Games_Awards"
    "https://en.wikipedia.org/wiki/7th_British_Academy_Games_Awards"
    "https://en.wikipedia.org/wiki/British_Academy_Games_Award_for_Narrative"
    "https://en.wikipedia.org/wiki/British_Academy_Games_Award_for_Multiplayer"
    "https://en.wikipedia.org/wiki/British_Academy_Games_Award_for_Game_Design"
    "https://en.wikipedia.org/wiki/British_Academy_Games_Award_for_Game_Beyond_Entertainment"
    "https://en.wikipedia.org/wiki/British_Academy_Games_Award_for_Family"
    "https://en.wikipedia.org/wiki/British_Academy_Games_Award_for_Evolving_Game"
    "https://en.wikipedia.org/wiki/British_Academy_Games_Award_for_Debut_Game"
    "https://en.wikipedia.org/wiki/British_Academy_Games_Award_for_British_Game"
    "https://en.wikipedia.org/wiki/British_Academy_Games_Award_for_Best_Game"
    "https://en.wikipedia.org/wiki/British_Academy_Games_Award_for_Artistic_Achievement"
    "https://en.wikipedia.org/wiki/British_Academy_Games_Award_for_Animation"
    # Above pages from Source: https://en.wikipedia.org/wiki/British_Academy_Games_Awards

    "https://en.wikipedia.org/wiki/The_Game_Awards"
    "https://en.wikipedia.org/wiki/The_Game_Awards_2024"
    "https://en.wikipedia.org/wiki/The_Game_Awards_2023"
    "https://en.wikipedia.org/wiki/The_Game_Awards_2022"
    "https://en.wikipedia.org/wiki/The_Game_Awards_2021"
    "https://en.wikipedia.org/wiki/The_Game_Awards_2020"
    "https://en.wikipedia.org/wiki/The_Game_Awards_2019"
    "https://en.wikipedia.org/wiki/The_Game_Awards_2018"
    "https://en.wikipedia.org/wiki/The_Game_Awards_2017"
    "https://en.wikipedia.org/wiki/The_Game_Awards_2016"
    "https://en.wikipedia.org/wiki/The_Game_Awards_2015"
    "https://en.wikipedia.org/wiki/The_Game_Awards_2014"
    "https://en.wikipedia.org/wiki/The_Game_Award_for_Game_of_the_Year"
    # Above pages from Source: https://en.wikipedia.org/wiki/The_Game_Awards

    "https://en.wikipedia.org/wiki/Game_Developers_Choice_Awards"
    "https://en.wikipedia.org/wiki/23rd_Game_Developers_Choice_Awards"
    "https://en.wikipedia.org/wiki/22nd_Game_Developers_Choice_Awards"
    "https://en.wikipedia.org/wiki/21st_Game_Developers_Choice_Awards"
    "https://en.wikipedia.org/wiki/20th_Game_Developers_Choice_Awards"
    "https://en.wikipedia.org/wiki/19th_Game_Developers_Choice_Awards"
    "https://en.wikipedia.org/wiki/Game_Developers_Choice_Award_for_Game_of_the_Year"
    # Above pages from Source: https://en.wikipedia.org/wiki/Game_Developers_Choice_Awards

    "https://en.wikipedia.org/wiki/Golden_Joystick_Awards"
    "https://en.wikipedia.org/wiki/Golden_Joystick_Award_for_Game_of_the_Year"
    # Above pages from Source: https://en.wikipedia.org/wiki/Golden_Joystick_Awards
    
    "https://en.wikipedia.org/wiki/The_Steam_Awards"
    # Above pages from Source: https://en.wikipedia.org/wiki/The_Steam_Awards

    "https://en.wikipedia.org/wiki/Independent_Games_Festival"
    "https://en.wikipedia.org/wiki/Seumas_McNally_Grand_Prize"
    "https://en.wikipedia.org/wiki/Nuovo_Award"
    # Above pages from Source: https://en.wikipedia.org/wiki/Independent_Games_Festival
)
url_update_date="May 2025 - first draft"

echo "URL Updated on: $url_update_date"

# ---------------------------------------------------------------
# Test the script with Halo
#  if nothing works:     1.a          3     -
#  if it already works:  1.b          3     -
#  Cleanup:              1.b          3     4.c

# 1.a. Create New folder ... and copy all webpages locally. (optional: you can comment this , if already in place)
#TMPDIR=$(create_temporary_directory)
#echo "Temporary directory: $TMPDIR"
#copy_html_urls_locally 

# 1.b. Or use existing folder with html files
TMPDIR="/tmp/tmp.SPub1tydQB"

# 3. Search for the keyword. Output the filename that contains it. 
grep -iFl "$search_term" "$TMPDIR"/*.html
grep -iFl "$search_term" "$TMPDIR"/*.md

# 4.c. Cleanup (optional: you can comment this out for debugging)
#rm -r "$TMPDIR"

# ---------------------------------------------------------------
