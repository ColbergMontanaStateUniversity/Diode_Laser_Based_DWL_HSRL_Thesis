% This function takes data from the afterpulsing data collection period and
% generates afterpulsing curves to be used to correct for afterpulsing in
% the HSRL code
clear all; close all;

%% 0. Pre-code
 % choose the date, for a single day, each variable should be a double
Date.day   = 24;  
Date.month = 8;
Date.year  = 2026;
% enter the UTC start and stop time for the afterpulsing measurement
Date.starttime = 4 + 15/60;
Date.endtime   = 4 + 55/60;

% define the file paths
Path.home        = pwd;
Path.RawData     = 'C:\Users\lukec\Desktop\WindLidarData\Raw_Data'; % folder containing the netCDF files
Path.NetCDF_code = 'C:\Users\lukec\Desktop\DWLandHSRLcode\LoadRawData'; % folder containing LoadNetCDF (the same function used by the main retrieval)
Path.save_data   = 'C:\Users\lukec\Desktop\WindLidarCalibrationAfterpulsingData\AfterpulsingData'; % folder where the afterpulsing .mat file is saved

%% 1. Loading the Raw Data
disp("Loading raw data")
% this section of the code loads the netCDF files
% navigate to the folder that contains the code for loading the raw data
cd(Path.NetCDF_code)

% function that loads raw data from the NetCDF file
[RawData] = LoadNetCDF(Date.day,Date.month,Date.year,Path);

% navigate back to the folder containing the main script
cd(Path.home)

%% 2. Sort the data into the appropriate bins
% function that trims and sorts the data into the appropriate bins
[RawData] = TrimAndSortAfterpulsing(RawData,Date);
    
%% 3. Determine the effect of after pulsing
% integrate the data into one profile
[Counts] = AverageDataAfterpulsing(RawData);

% subtract the background
[Afterpulsing] = BackgroundSubtraction(Counts);

%% 4. Save the Data
cd(Path.save_data)
filename = strcat('Afterpulsing_',num2str(Date.year));
if Date.month<10
    filename = strcat(filename,'0',num2str(Date.month));
else
    filename = strcat(filename,num2str(Date.month));
end
if Date.day<10
    filename = strcat(filename,'0',num2str(Date.day));
else
    filename = strcat(filename,num2str(Date.day));
end

save(filename,'Afterpulsing')
cd(Path.home)