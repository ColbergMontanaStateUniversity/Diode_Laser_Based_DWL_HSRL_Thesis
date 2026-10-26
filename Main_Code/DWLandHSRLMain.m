% This code finds the Radial Wind Velocity using the double-edge technique

clear all; close all;

% Check if a parallel pool is already open
pool = gcp('nocreate'); % If no pool, do not create a new one

% % If no pool exists, create a new one
if isempty(pool)
    pool = parpool('local'); % Start a new parallel pool with default settings
end

%% 0. Pre-code
 % choose the date, for a single day, each variable should be a double
Date.day   = (1);
Date.month = (9);
Date.year  = 2026*ones(1,1);

% define unchanging constants
Constants = define_constants;

% define the file paths
[Path] = define_paths;

%%%%% User defined options %%%%%

% integration options
Options.time_step  = 15; % minutes
Options.range_step = 4;  % bins, (1 bin is approximately 37.5 meters)

% pulse length and delay options
Options.Pulse_length = 1e-6  ; % s
Options.TSOA_delay   = 200e-9; % s
Options.Sync_delay   = 200e-9; % s
Options.Bin_width    = 250e-9; % s

% Afterpulsing correction, select filename of afterpulsing correction
Options.Afterpulsing_filename = "Afterpulsing_20260824.mat";

% Receiver curves, select filename of the calibration receiver scans
Options.ReceiverScans_filename = "20260914_Curves.mat";

% HSRL Calibration Tables, select filename of the HSRL calibration tables
Options.HSRLCalTables_filename = "20260914_calibration.mat";

% avalanche photodiode detector deadtime
Options.APD_deadtime = 22e-9; % s

% minimum range
Options.low_bin = 10; % bin, the lowest range bin to be used in the lidar retrieval, this variable uses 1 bin = 37.5 m

% background subtraction
Options.background_height = 17500; %m, the altitude of the lowest range bin where the data is assumed to be entirely background

% Poisson Thinning Options
Options.bootstrap_iterations = 20;

%% 1. Loading the Raw Data and the HSRL
disp("Loading data")
% this section of the code loads the netcdf files, the weather station

% navigate to the folder that contains the code for loading the raw data
cd("LoadRawData")

% function that loads raw data from the NetCDF file
[RawData] = LoadNetCDF(Date.day,Date.month,Date.year,Path);

% function that loads raw data from the weather station
[HRRRData] = LoadHRRRData(Date.day,Date.month,Date.year,Path);

% function that loads the receiver data
[Receiver] = LoadReceiver(Path,Options);

% function that loads the HSRL calibration tables
[HSRLCal] = LoadHSRLCalibration(Path,Options);

% navigate back to the folder containing the main script
cd(Path.home)

%% 2. Sort, correct, and trim the data
disp("Sorting data")
% this section of the code takes the raw counts from the NetCDF files and 
% sorts them into channels, corrects for afterpulsing and nonlinear photon
% counting effects, trims data below a low-range threshold and integrates 
% them into the desired range and time bins

%navigate to the folder that contains the code for sorting and integrating
cd("SortAndIntegrateData")

%function that sorts the MCS data
[RawData] = SortData(RawData);

disp("Correcting for afterpulsing")

%function that corrects for afterpulsing
[RawData] = AfterpulsingCorrection(RawData,Path,Options);

disp("Removing low-range data")
% function that trims data below Options.low_bin
[RawData] = TrimLowRanges(RawData,Options);

disp("Correcting for deadtime")
% function that corrects for nonlinear photon counting effects
[RawData] = PhotonCountingCorrection(RawData,Options);

disp("Integrating data")

%function that integrates the data to the desired range and time bins
[Counts] = IntegrateData(RawData,Options,Constants);

%navigate back to the home folder
cd(Path.home)

%% 3. Apply Poisson thinning and convert to count rates
cd("ConvertToCountRatePThin")

disp("Applying Poisson thinning")

% apply the Poisson thinning
tic
[Counts] = PoissonThinCounts(Counts,Options);
toc

disp("Subtracting Background")

% subtract background
[Counts] = BackgroundSubtractionPThin(Counts,Options);

disp("Converting to Count Rate")

% convert to count rate
[Counts] = ConvertToCountRatePThin(Counts,Options,RawData);

disp("Finding Count Ratio")

% find the count ratio
[Counts] = FindDDSignalPThin(Counts); 

% navigate back to the folder containing the main script
cd(Path.home)

%% 4. Model the Atmosphere

disp("Generating Modeled Atmosphere")

% navigate to the directory that contains the atmosphere modeling code
cd("ModelAtmosphere")

% create temperature and pressure field
[Atmosphere] = CreateAtmosphere(HRRRData,Constants,Counts);

%create Cabannes spectrum for each cell
[Atmosphere] = CreateCabannesSpectrum(Atmosphere,Path);

% navigate back to the home folder
cd(Path.home)

%% 5. Perform HSRL Retrieval
% this section is where the counts and the modeled atmosphere is turned
% into the calibrated aerosol backscatter

disp("Performing the HSRL Retrieval")

% navigate to the folder containing the HSRL retrieval code
cd("HSRLRetrieval")
%function that determines the backscatter ratio, the aerosol backscatter
%coefficient and the associated uncertainties
tic
[HSRL] = HSRLRetrievalPThin(Counts,Atmosphere,HSRLCal,Options);
toc
% function that determines the uncertainty of the backscatter ratio and the
% aerosol backscatter coefficients
[HSRL] = HSRLUncertaintyPThin(HSRL,Options);

% navigate to the home folder
cd(Path.home)

%% 6. Find the Radial Wind Velocity

disp("Finding the Radial Wind Velocity")

% navigate to the folder that contains the code to find the radial wind
% speed
cd('FindRadialWinds')

%function that finds the Radial Wind Velocity using the measured
%direct-detection signal, the measured backscatter ratio, the measured
%transmission curves of the etalons, and the modeled atmospheric Cabannes
%spectra

[Winds] = FindDopplerShift(Counts,HSRL,Receiver,Atmosphere);

[Winds] = FindDopplerShiftPThin(Winds,Counts,HSRL,Receiver,Atmosphere,Options);

[Winds] = ConvertDopplerShiftToWindSpeed(Winds);

[Winds] = WindUncertaintyPThin(Winds,Options);

% navigate home
cd(Path.home);

%% 7. Create Mask
cd('CreateMask')

[HSRL] = CreateHSRLUncertaintyMask(HSRL);
[Winds] = CreateWindUncertaintyMask(Winds);

Winds.Mask(HSRL.Mask==1)=1; 

cd(Path.home)

%% 8. Create plots
% many hardcoded lines in this section that will have to be changed.
% dependent on crameri colormaps as written.
cd('C:\Users\lukec\Desktop\Colormaps')
cmap1 = crameri('batlow');
cmap2 = flipud(crameri('roma'));
cd(Path.home)

figure(1)
set(gcf, 'Units', 'inches', 'Position', [1 1 7.5 2.5], 'Color', 'w')
hold on
imagesc(HSRL.t,HSRL.r,HSRL.BR); set(gca,'ydir','normal')
colorbar
colormap(cmap1)
clim([1 1e2])
set(gca,'colorscale','log')
xlabel('Hours since 0:00 UTC')
ylabel('Range (m)')
title('Backscatter Ratio at 780 nm (Unitless)')
ylim([0 11000])
xlim([0 24])
black = zeros([size(HSRL.Beta_aer) 3]);
h = imagesc(HSRL.t,HSRL.r,black);
set(h, 'AlphaData', HSRL.Mask == 1);

set(gca, 'FontName', 'Times New Roman', 'FontSize', 12)
set(get(gca,'XLabel'), 'FontName', 'Times New Roman', 'FontSize', 12)
set(get(gca,'YLabel'), 'FontName', 'Times New Roman', 'FontSize', 12)
set(get(gca,'Title'),  'FontName', 'Times New Roman', 'FontSize', 12)

figure(2)
set(gcf, 'Units', 'inches', 'Position', [1 1 7.5 2.5], 'Color', 'w')
hold on
imagesc(Winds.t,Winds.r,Winds.Vr); set(gca,'ydir','normal')
colorbar
colormap(cmap2)
clim([-5 5]) 
xlabel('Hours since 0:00 UTC')
ylabel('Range (m)')
title('Radial Wind Velocity (m/s)')
ylim([0 11000])
xlim([0 24])

black = zeros([size(Winds.Vr) 3]);
h = imagesc(Winds.t,Winds.r,black);
set(h, 'AlphaData', Winds.Mask == 1);

set(gca, 'FontName', 'Times New Roman', 'FontSize', 12)
set(get(gca,'XLabel'), 'FontName', 'Times New Roman', 'FontSize', 12)
set(get(gca,'YLabel'), 'FontName', 'Times New Roman', 'FontSize', 12)
set(get(gca,'Title'),  'FontName', 'Times New Roman', 'FontSize', 12)