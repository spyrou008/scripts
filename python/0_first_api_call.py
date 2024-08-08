# Quick python script
# How to use: run the following
#  python3 ~/github/scripts/python/0_first_api_call.py

# Quick print
print("This line will be printed.")

# Quick API call

# The module "Requests" allows to send HTTP requests
# Download the `request` python module from : https://pypi.org/project/requests/
#  and extract the folder to get something like this: ./requests/api.py
import requests

# if the below lines do not work anymore , try to paste the below URL in a web browser. it should work or directed , or else ?
url = "http://api.open-notify.org/astros.json"
response = requests.get(url)
data = response.json()
print(response.status_code)
print(data)
print("message : " + data['message'])


# write output into a file: 
filenamepath = "~/github/scripts/python/0_outfile.txt"
filenamepath = "./0_outfile.txt"
f = open(filenamepath, "w")
print("astros.json content: ", file=f)
print(data, file=f) ## You can't write a dictionary to a string. Either use print(file=file_object) or f.write(str(...)).
f.close()
