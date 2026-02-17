import pandas as pd
import glob
import os

def load_all_masspa(data_dir):
    all_records = []
    # Recursively find all .txt files in your new masspa_2017_data folder
    files = glob.glob(os.path.join(data_dir, "**/*.txt"), recursive=True)
    
    for file in files:
        with open(file, 'r') as f:
            for line in f:
                if line.startswith("DATA,POW"):
                    # Basic split logic (you can expand this with the parser from before)
                    parts = line.split(',')
                    int_values = parts[3].split(':')[1:] # The INT section
                    # Using Index 6 (Mass 16) as a methane proxy
                    all_records.append({
                        "methane_raw": float(int_values[6]),
                        "timestamp": os.path.basename(file).split('.')[0] # Use filename for time
                    })
    
    df = pd.DataFrame(all_records)
    df['timestamp'] = pd.to_datetime(df['timestamp'], format='%Y%m%d_%H%M%S', errors='coerce')
    return df.set_index('timestamp').sort_index()

# Usage:
# df = load_all_masspa("masspa_2017_data")