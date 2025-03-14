import pandas as pd
import requests
import os

api_semanticscholar = "Adi2eCpEum93RUce0fgJb4oXZgpbIQLf1JQEdJwZ"
# Set up the URL and the headers
url = 'https://api.semanticscholar.org/datasets/v1/release/'
headers = {'x-api-key': api_semanticscholar}

# Send the GET request
response = requests.get(url, headers=headers)
latest = response.json()[-1]

url = 'https://api.semanticscholar.org/datasets/v1/release/' + latest + '/dataset/s2orc'
response = requests.get(url, headers=headers)
json_data = response.json()
files_url = json_data['files']
save_directory = '/Volumes/Samsung_T5/S2ORC'

# read downloaded_list
downloaded_list = []
if os.path.exists('downloaded_list.txt'):
    with open('downloaded_list.txt', 'r') as f:
        downloaded_list = f.read().splitlines()
# Download the files
for url in files_url:
    #check if the file has already been downloaded
    if url.split('/')[-1].split('?')[0] in downloaded_list:
        print(f"Skipping: File {url.split('/')[-1].split('?')[0]} already downloaded")
        continue
    try:
        # Extract the file name from the URL
        file_name = url.split('/')[-1].split('?')[0]
        # Create the path to save the file
        save_path = os.path.join(save_directory, file_name)
        
        # Send a GET request to the URL
        response = requests.get(url)
        # Raise an exception if the request was unsuccessful
        response.raise_for_status()
        
        # Write the contents of the response to a file
        with open(save_path, 'wb') as file:
            file.write(response.content)
        print(f"Downloaded {file_name} to {save_path}")
        downloaded_list.append(file_name)
        #save the list of downloaded files
        with open('downloaded_list.txt', 'w') as f:
            for item in downloaded_list:
                f.write("%s\n" % item)
    except requests.RequestException as e:
        # Handle any errors that occur during the download process
        print(f"Error downloading {url}: {e}")