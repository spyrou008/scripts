#!/bin/bash
##!/usr/bin/bash

# Execute me : 
# 	bash ~/github/scripts/extract-game-details-from-URL.sh <URL>

# v.0.1 ChatGPT initial version

# FYI: this script allows to extract details from websites so that it is quicker to do copy paste

# Check if the script was provided exactly one argument
if [ $# -ne 1 ]; then
  echo "Usage: $0 <URL>"
  exit 1
fi

# Store the first argument in a variable
s_url="$1"

# Check if the provided argument is a valid URL
# Using curl to check if the URL is reachable
if curl --head --silent --fail "$s_url" > /dev/null; then
    echo ""
#  echo "The URL '$s_url' is valid and reachable."
else
    echo "Error: The URL '$s_url' is either invalid or not reachable."
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
#  echo "domain_hash: "
#  echo "$domain_hash"

if [[ $domain_hash == "4912f7166455474accd0067e1ddd00435279777d7464a5fb15465a526272e084  -" ]]; then
    echo "Info: Domain 1: $domain"
    # 1. Extract the Header1 (inside <h1>...</h1>)
    s_HeaderOne=$(echo "$HTML_CONTENT" | grep -oP '(?<=<h1> ).*?(?= </h1>)')
    # Use sed to remove everything after "Appid" or "jc"
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
    echo "bash ~/Downloads/torrents/Games/1_test/$s_folder_name""/start"
    echo ""
    exit 0


elif [[ $domain_hash == "ebed7e0a437b1eda3d85886c7258acac9445546b0c35d10e9e922bfef12aef77  -" ]]; then
    echo "Info: Domain 2: $domain"
    echo "Info: Title: $TITLE"
    echo "Info: Header1: $(echo "$HTML_CONTENT" | grep -oP '(?<=<h1> ).*?(?= </h1>)')"

else
    echo "Error: Unknown domain: $domain"
    
    exit 3
fi
