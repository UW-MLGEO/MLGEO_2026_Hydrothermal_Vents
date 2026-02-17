import pandas as pd
import matplotlib.pyplot as plt

# 1. Load the data
file_path = "MASSPA_2017_Full_Year.csv"

try:
    # We tell pandas to treat the first column as a Date
    df = pd.read_csv(file_path, index_col=0, parse_dates=True)
    
    # 2. Setup the figure
    plt.figure(figsize=(16, 7))

    # 3. Plot the Raw Hourly Data (Light teal)
    plt.plot(df.index, df['methane_m16'], 
             color='#008080', alpha=0.3, linewidth=1, label='Hourly Methane Intensity')

    # 4. Plot a 7-day Moving Average (Bright red)
    # This helps see the 'trend' through the noise
    rolling_mean = df['methane_m16'].rolling(window=24*7, min_periods=24).mean()
    plt.plot(df.index, rolling_mean, 
             color='#e63946', linewidth=2, label='7-Day Rolling Average')

    # 5. Formatting
    plt.title("MASSPA Methane Concentration - 2017 Full Year Analysis", fontsize=16)
    plt.ylabel("Methane Intensity (Mass 16 Counts)", fontsize=12)
    plt.xlabel("Month", fontsize=12)
    plt.grid(True, which='major', linestyle='--', alpha=0.5)
    
    # This automatically formats the months on the X-axis
    plt.gcf().autofmt_xdate()
    
    plt.legend()
    plt.tight_layout()

    # 6. Save and Show
    plt.savefig("Methane_2017_Analysis_Plot.png", dpi=300)
    print("✅ Plot generated and saved as 'Methane_2017_Analysis_Plot.png'")
    plt.show()

except FileNotFoundError:
    print(f"❌ Error: Could not find '{file_path}'. Make sure it's in the same folder as this script.")