This code processes laser frequency calibration scans of the lidar receiver. The transmission curve script generates the blue-shifted and red-shifted etalon transmission curves used in the DWL retrieval. The calibration constant script generates the HSRL calibration constants (Cmm, Cmc, Cam, Cac) over a grid of temperature and pressure. LoadMCS.m reads the MCS netCDF files and is used by both scripts. Requires MATLAB.

User-adjustable settings (scan file, date, background window, reference wavelength, dead time, and the temperature and pressure grid) are in the %% 0.Pre-code section at the top of each script. The data, PCA, and saving output directories will also need to be replicated or changed.

The calibration constant script requires the CalibrationConstantCode and PlottingCode folders and the PCA file produced by the Cabannes spectra training set code.
