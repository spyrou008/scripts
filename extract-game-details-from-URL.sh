#!/bin/bash
##!/usr/bin/bash

# Execute me : with either one URL or several
# 	bash ~/github/scripts/extract-game-details-from-URL.sh URL1 [URL2 URL3 ...]

# v.0.1 ChatGPT initial version + Cursor. 

# FYI: this script allows to extract details from websites so that it is quicker to do copy paste


# Function to extract content from a single URL
extract_content() {

    # Store the first argument in a variable
    s_url="$1"

    # Check if the provided argument is a valid URL
    # Using curl to check if the URL is reachable
    if curl --head --silent --fail "$s_url" > /dev/null; then
        echo ""
    #  echo "The URL '$s_url' is valid and reachable."
    else
        echo "Error: The URL '$s_url' is either invalid or not reachable."
        echo "Error: Exit script."
        exit 2
    fi

    # get the full response with the body
    # response=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" --location "$s_url")
    # Extract the body and the HTTP status code
    # body=$(echo "$response" | sed -e 's/HTTPSTATUS:.*//')
    # status_code=$(echo "$response" | sed -e 's/.*HTTPSTATUS://')

    # Fetch the HTML content of the page
    HTML_CONTENT=$(curl -s "$s_url")

    # 1. Extract the title (inside <title>...</title>)
    TITLE=$(echo "$HTML_CONTENT" | grep -oP '(?<=<title>).*?(?=</title>)')

    #  Extract the base URL (protocol + domain)
    base_url=$(echo "$s_url" | sed -E 's#^(https?://[^/]+).*#\1#')
    #  echo "Base URL: "
    #  echo "$base_url"

    base_url_no_proto=${s_url#*://}  # Remove protocol (http:// or https://)
    domain=${base_url_no_proto%%/*} # Remove everything after the domain
    #  echo "base_url_no_proto: "
    #  echo "$base_url_no_proto"
    #  echo "domain: "
    #  echo "$domain"

    domain_hash=$(echo -n "$domain" | sha256sum) # hashing

    if [[ $domain_hash == "4912f7166455474accd0067e1ddd00435279777d7464a5fb15465a526272e084  -" ]]; then
        # echo "Info: Domain 1: $domain"
        # 1. Extract the Header1 (inside <h1>...</h1>)
        s_HeaderOne=$(echo "$HTML_CONTENT" | grep -oP '(?<=<h1> ).*?(?= </h1>)')
        # Use sed to remove everything after "Appid" or "MULTi"
        s_ShortTitle=$(echo "$s_HeaderOne" | sed 's/ \(MULTi\|GNU\/\|jc1\|(Appid\).*//')

        # Get the Date s_date , with a search
        #  echo "Search: "
        s_url2=$(echo "$s_HeaderOne" | sed 's/[[:space:]]/+/g' | sed 's/[\/-]/+/g')
        #  echo "$s_url2"
        #  echo "Search URL: "
        s_search_url_sp="$base_url /search/ $s_url2 /1/"
        s_search_url=$(echo "$s_search_url_sp" | sed 's/[[:space:]]//g')
        #  echo "$s_search_url"
        content_search=$(curl -s "$s_search_url")

        #  Extract the search date (inside <td class="coll-date">...</td>)
        s_date=$(echo "$content_search" | grep -oP '(?<=<td class="coll-date">).*?(?=</td>)')
        ## 1. Extract the Date and Parse It. Using date to Convert the Format
        # Remove the "st", "nd", "rd", "th" suffix from the day part
        cleaned_date=$(echo "$s_date" | sed -E 's/(st|nd|rd|th)//')
        # echo "Cleaned Date1: $cleaned_date"
        # Replace the year format to ensure it's in the full four-digit format (e.g., '24 -> 2024)
        cleaned_date=$(echo "$cleaned_date" | sed "s/'/20/")
        # echo "Cleaned Date2: $cleaned_date"
        # Convert the cleaned date into YYYY-MM-DD using the `date` command
        formatted_date=$(date -d "$cleaned_date" +"%Y-%m-%d")

        # 2. Extract the list items containing <strong>Total size</strong>
        # s_size_p=$(echo "$HTML_CONTENT" | grep -oP '<li>.*?<strong>Total size.*?</strong>.*?</li>') 			# Total size 1MB
        s_size_p=$(echo "$HTML_CONTENT" | grep -oP '(?<=<li> <strong>Total size</strong> <span>).*?(?=</span> </li>)') 	# 1MB
        # Strip HTML tags for readability
        s_size=$(echo "$s_size_p" | sed 's/<[^>]*>//g')

        # 3. Extract the paragraph 
        # Use sed to extract content starting with <p><img> and ending with "SETUP AND SUPPORT", <span>, or <img>
        # PARAGRAPH=$(echo "$HTML_CONTENT" | sed -n '/<p><img[^>]*>/,/\(SETUP AND SUPPORT\|Global and local\|<span\|<img\)/p')
        # Use perl to extract content starting with <p><img> and ending with "SETUP AND SUPPORT", <span>, or <img>
        # PARAGRAPH=$(echo "$HTML_CONTENT" | perl -0777 -ne 'if (/<p><img[^>]*>.*?(SETUP AND SUPPORT|<span>|<img>)/s) { print "$&\n"; }')
        # echo "$PARAGRAPH"

        # 4. Extract the folder name (I remove the 1 and replace the 1 just after)
        s_folder_name=$(echo "$HTML_CONTENT" | grep -oP '(?<=<span class="head"><i class="flaticon-folder"></i>).*?(?=1</span>)')
        s_folder_name="$s_folder_name""1"
        # echo "$s_folder_name"

        echo "--------------------------------------------------------------------------------------------"
        echo "# $s_ShortTitle"
        echo "			qBittorrent	???"
        echo "$s_url"
        echo "$TITLE"
        echo "Date: $s_date"
        echo "Date: $formatted_date"
        echo "Size: $s_size"
        echo "/share/CACHEDEV1_DATA/data/downloads/2-games/$s_folder_name"
        # echo "$PARAGRAPH" | sed 's/<[^>]*>//g'  # Strip HTML tags for readability
        # echo ""
        echo ""
        echo "..."
        echo ""
        echo "bash ~/Downloads/torrents/Games/2_test/$s_folder_name""/start"
        echo ""
        echo "? # Replaces: "

    elif [[ $domain_hash == "ebed7e0a437b1eda3d85886c7258acac9445546b0c35d10e9e922bfef12aef77  -" ]]; then
        echo "Info: Domain 2: $domain"

        local HTML_CONTENT=$(curl -s "$s_url")
        # echo "$HTML_CONTENT" > "temp.txt" # Only used for debugging purposes or write the grep functions outside inthe command line. 


        # Extract game details
        local game_title=$(echo "$HTML_CONTENT" | grep -oP '(?<=<h2>About ).*?(?=</h2>)')
        local game_description=$(echo "$HTML_CONTENT" | grep game-description-wrapper -A 4 | grep "game-description description-text" -A 1 | grep -oP '(?<=">).*?(?=<)')
        local released_date=$(echo "$HTML_CONTENT"  | grep game-info-details-section-release -A 3 | grep game-info-details-content | grep -oP '(?<=game-info-details-content).*?(?=</p>)' | sed 's|[">]||g')
        local platforms=$(echo "$HTML_CONTENT" | grep game-info-inner-heading -A 5 | grep Platforms -A 5 | grep -oP '(?<=title).*?(?=href)' | sed 's|[="]||g' | sed 's/[[:blank:]]*$//' | paste -s -d ',')
        local genres=$(echo "$HTML_CONTENT" | grep game-info-genres -A 3 | grep badges-container | grep -oP '(?<=/">).*?(?=</a>)' | paste -s -d ',')
        local tags=$(echo "$HTML_CONTENT" | grep game-info-tags -A 3 | grep Tags -A 2 | grep badges-container | grep -oP '(?<=/">).*?(?=</a>)' | paste -s -d ',')
        local game_modes=$(echo "$HTML_CONTENT" | grep game-info-tags -A 3 | grep "Game modes:" -A 2 | grep -oP '(?<=/">).*?(?=</a>)' | paste -s -d ',')

        # Print the extracted details
        echo "--------------------------------------------------------------------------------------------"
        # echo "Title: "
        echo $game_title
        echo "Released Date: $released_date"
        echo "Platforms: $platforms"
        echo "Genres: $genres"
        echo "Tags: $tags"
        echo "Game Modes: $game_modes"
        echo "Description: "
        echo $game_description        

    elif [[ $domain_hash == "cf072d98f3749cb00754b9cdd663e699318e6706753174173bbae19f2c3184d2  -" ]]; then
        # echo "Info: Domain 3: $domain"

        local HTML_CONTENT=$(curl -s "$s_url")
        # echo "$HTML_CONTENT" > "temp.txt" # Only used for debugging purposes or write the grep functions outside inthe command line. 
        # e.g:
        # cat ~/temp.txt  | grep -oP '(?<=<a class=\"screen-item no-underline\" href=\").*?(?=\">)' | while read line; do
        #     echo "[img]$line[/img]"
        # done

        # Extract game details
        local game_title=$(echo "$HTML_CONTENT" | grep -oP '(?<=<title>).*?(?= Database</title>)')
        local developers=$(echo "$HTML_CONTENT" | grep "<td>Developers</td>" -A 1 | sed 's|Developers||g' | grep -oP '(?<=<td>).*?(?=</td>)')
        local publisher=$(echo "$HTML_CONTENT" | grep "<td>Publisher</td>" -A 1 | sed 's|Publisher||g' | grep -oP '(?<=<td>).*?(?=</td>)')
        local genres=$(echo "$HTML_CONTENT" | grep "<td>Tags</td>" -A 1 | sed 's|Tags||g' | grep -oP '(?<=<td>).*?(?=</td>)')
        local features=$(echo "$HTML_CONTENT" | grep "<td>Features</td>" -A 1 | sed 's|Features||g' | grep -oP '(?<=<td>).*?(?=</td>)')
        local platforms=$(echo "$HTML_CONTENT" | grep "<td>Supported sytems</td>" -A 1 | sed 's|Supported sytems||g' | grep -oP '(?<=fa-).*?(?=")'  | paste -s -d ',')
        local released_date=$(echo "$HTML_CONTENT" | grep "Global release date" -A 1 | sed 's|Global release date||g' | grep -oP '(?<=<td>).*?(?=</td>)')
        local game_link="http"$(echo "$HTML_CONTENT" | grep "Store link" -A 5 | grep -oP '(?<=>http).*?(?=</a>)')
        local game_logo="http"$(echo "$HTML_CONTENT" | grep ">Logo<" -A 5 | grep -oP '(?<=>http).*?(?=</a>)')
        local game_img_list=$(echo "$HTML_CONTENT" | grep -oP '(?<=<a class=\"screen-item no-underline\" href=\").*?(?=\">)')
        echo $game_img_list > /tmp/game_img_list.txt

        # Print the extracted details
        # echo "--------------------------------------------------------------------------------------------"
        # echo "Title: "
        # echo $game_title
        # echo "Developers: $developers"
        # echo "Publisher: $publisher"
        # echo "Genres: $genres"
        # echo "Features: $features"
        # echo "Supported sytems: $platforms"
        # echo "Released Date: $released_date"
        # echo "Store Page: $game_link"
        # echo "Database Page: $s_url"
        # echo "- Logo: $game_logo"
        echo "--------------------------------------------------------------------------------------------"
        echo "Some game details: (move the below in the main post if you can)"
        echo ""
        echo "[img]$game_logo[/img]"
        echo ""
        echo "[b][color=#0000BF]$game_title[/color][/b]"
        echo ""
        echo "[b]Genre:[/b]	$genres"
        echo "[b]Features:[/b]	$features"
        echo "[b]Supported sytems:[/b] $platforms"
        echo "[b]Released Date:[/b] $released_date" # change 2024-10-07 into October 7, 2024
        echo "[b]Company:[/b]	$developers / $publisher"
        echo "[b][url=$game_link]G0G Store Page[/url][/b] || [b][url=$s_url]G0GDB Page[/url][/b]"
        echo "[spoiler=Screenshots]"
        # cat /tmp/game_img_list.txt | while read game_img; do  echo "[img1]$game_img[/img]"; done
        # Loop through each line in the temporary file and wrap with BBCodes
        while read game_img; do
            echo "[img]$game_img[/img]"  | sed 's|webp https|webp[/img] [img]https|g'
        done < /tmp/game_img_list.txt
        # Optionally, clean up the temporary file after processing
        rm /tmp/game_img_list.txt
        echo "[/spoiler]"
        echo "

----------
Can add: if available
Size
PCGamingWiki Page link
About
System requirements

You cannot use certain BBCodes: [media].
[spoiler=Videos]bla-bla-bla[/spoiler]
"

    else
        echo "Error: Unknown domain: $domain"
          echo "domain_hash: "
          echo "$domain_hash"
    fi

}

# Check if URLs are provided
if [ $# -eq 0 ]; then
    echo "Error: Please provide at least one URL as argument"
    echo "Usage: $0 URL1 [URL2 URL3 ...]"
    exit 1
fi

# Process each URL provided as argument
for url in "$@"; do
    echo ""
    echo ""
    echo ""
    echo "Info: Extracting URL: $url"
    extract_content "$url"
done
