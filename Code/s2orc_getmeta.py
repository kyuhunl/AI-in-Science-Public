import os
import gzip
import json
import pandas as pd

# Directory containing the .gz files
directory = '/Volumes/Samsung_T5/S2ORC'

# Initialize an empty list to hold the metadata
metadata = []

# Get a list of all .gz files in the directory
gz_files = [f for f in os.listdir(directory) if f.endswith('.gz') and not f.startswith('.')]

# Loop over the list of .gz files
i = 0
length = len(gz_files)
for gz_file in gz_files:
    i += 1
    #testing with a single file
    if i > 1:
        break
    print(f"Processing {gz_file} ({i}/{length})")
    with gzip.open(os.path.join(directory, gz_file), 'rt') as f:
        for line in f:
            data = json.loads(line)
            # Extract the required entries
            entries = { 'corpusid': data.get('corpusid'),
                       'externalids': data.get('externalids'),
                       'source': data.get('content', {}).get('source')}
            metadata.append(entries)

# Convert the metadata list to a pandas DataFrame
df = pd.DataFrame(metadata)

# Save the DataFrame to a CSV file
df.to_csv('metadata.csv', index=False)