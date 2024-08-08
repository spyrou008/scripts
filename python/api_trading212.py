# Quick python script
# How to use: run the following
#  python3 ~/github/scripts/python/api_trading212.py

# ----------------------------------------------------------------------------
# TODO :
# TODO 1. for a given ISIN , Find the SYMBOL for a list of currencies when they are available. eg: ISIN=IE00B5BMR087 > GBX:CSP1 & EUR:SXR8
# 		I am interested in ETFs available for a specific set of currencies. and their performance for the last year
# TODO 2. parse the list of instrument with json. to manipulate the data. get the current price, get the price a year ago.
# TODO 3. Try to call https://www.justetf.com/api/etfs/GB00BJYDH287/quote?locale=it&currency=EUR for a given ISIN
# as per https://www.reddit.com/r/sheets/comments/16k0b0o/how_can_i_extrat_and_etf_value_from_a_website/
# ----------------------------------------------------------------------------

# Quick API call

# The module "Requests" allows to send HTTP requests
# Download the `request` python module from : https://pypi.org/project/requests/
#  and extract the folder to get something like this: ./requests/api.py
import requests

# trading212 API details here: 
#  https://t212public-api-docs.redoc.ly/#operation/instruments


# All trading instruments here
urldemo = "https://demo.trading212.com/api/v0/equity/metadata/instruments" # does NOT work
urllive = "https://live.trading212.com/api/v0/equity/metadata/instruments"
url = urllive

# PRIVATE !!!!!!!
headers = {"Authorization": "YOUR_API_KEY_HERE"} # PRIVATE !!!!!!!
# PRIVATE !!!!!!!

response = requests.get(url, headers=headers)
data = response.json()
print(response.status_code)
print(data)
# print("message : " + data['message'])


# write output into a file: 
f = open("outfile.txt", "w")
print("trading212 content: ", file=f)
print(data, file=f) ## You can't write a dictionary to a string. Either use print(file=file_object) or f.write(str(...)).
f.close()

# If the file is too big , mousepad , cannot open it. Use something else. 
# FYI used this website to convert JSON into CSV: https://www.convertcsv.com/json-to-csv.htm