# MLGEO_2026_Methane_Seeps
Repository for Southern Hydrate Ridge team Michael, Christina, Isaac, and David

Link to onedrive: https://uwnetid-my.sharepoint.com/:f:/r/personal/lolson04_uw_edu/Documents/Submarine_volcanoes_onedrive?csf=1&web=1&e=v089IY

## Notes from Wed 2/11 Class meeting:

** Oxygen may no longer be an option!
Partial pressure of CO2 may work as an alternative
salinity may also work (check to see if SHR emits brine)
conductivity could work

Fluorometer for fidoplankton activity (David will look at this)

Check to see how o2 varies throughout all time to see if pattern emerges despite low overall o2 (Michael's on it)

** Data processing discussion
We will store output CSV files and assuming we don't run out of space original data files of whatever types on the shared onedrive

** Plan for producing training data
Pull out mean, max, and min from sonar data
Reprocess seismic data (three components, x, y, z) to 1 hour chunks with mean max min amplitude, 1st dominant frquency and spectral power associated with that frequency.
Use tidal data to denoise other data

Plan to do all this by next Thursday's meeting.

## Notes from Wed 2/18 Class meeting:

### Training Inputs: 
  1. Seismic features (frequency, amplitude, spectral power) for three components, 2017
     - Subtract off surface wave noise with highpass >= 2 Hz.
       
  2. Bubble velocity meter from ADCP acoustic, 2017
     - Subtract off background water velocity
       
** Note: We have analyzed seafloor pressure data to understand how tidal trends correlate to our time series data, but the diurnal and seasonal cycles are not relevant at our time scales. **

### Training Target:
Dissolved methane concentration in seawater at the methane seep site, 2017.
- Originates from PI mass spectrometer deployed at Southern Hydrate Ridge, 2014-2017.
- Data pulled from OOInet raw data site as Mass (AMU) vs. Pressure (Torr) spectra taken every 22 seconds
- Calculate partial pressure as the pressure at a mass peak of 16 amu (with methane's mass at 16.04 amu) divided by the total pressure of the sample.
- Use Henry's Law for dissolved gas concentration in aqueous solution: C (Concentration) = kH (Henry's Constant) * P (Partial pressure) * 1e9 (scale factor - convert from M/L to nM/L)
- In our case, Henry's Constant for methane at a temperature appropriate for the 770m seafloor depth of the site, is 1.3e-3.
    

