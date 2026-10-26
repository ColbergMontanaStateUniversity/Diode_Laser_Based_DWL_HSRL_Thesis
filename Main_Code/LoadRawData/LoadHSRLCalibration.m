function [HSRLCal] = LoadHSRLCalibration(Path,Options)

% This function loads the HSRL calibration tables produced by the HSRL
% calibration script. HSRLCal contains Temperature (K), Pressure (hPa),
% and the calibration constants Cmm, Cmc, Cam, and Cac, each indexed as
% (temperature, pressure).

cd(Path.HSRLCal)

load(Options.HSRLCalTables_filename);
HSRLCal = Results;

cd(Path.home)

end