This code generates the afterpulsing curves used to correct for afterpulsing in the DWL and HSRL retrieval. 

Afterpulsing_main loads the MCS netCDF files for a chosen date, keeps only the data within the afterpulsing measurement window, averages each channel into a single profile, and subtracts a background estimated from the last 50 range bins. 

The output is saved as Afterpulsing_YYYYMMDD.mat and is loaded by the main retrieval through Options.Afterpulsing_filename. Requires MATLAB.
