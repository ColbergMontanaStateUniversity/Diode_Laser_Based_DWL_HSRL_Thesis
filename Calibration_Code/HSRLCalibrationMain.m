% Generates the HSRL calibration constants (Cmm, Cmc, Cam, Cac) over a
% grid of temperature and pressure from a laser frequency calibration scan.
%
% Inputs:
%   - ILX/wavemeter scan file (Path.WaveFilename) located in Path.WaveData
%   - MCS netCDF files located in Path.RawData/<Date_string>/
%   - PCA file produced by the Cabannes_PCA code
% Output (saved as <Date_string>_calibration.mat):
%   Results - structure containing Temperature, Pressure, Cmm, Cmc, Cam, Cac
%
% Run from the folder containing this script. Requires LoadMCS.m and the
% CalibrationConstantCode and PlottingCode subfolders.
clear all; close all;


%% 0.Pre-code

%define Paths
Path.home = pwd;
Path.MCSData     = "C:\Users\lukec\Desktop\WindLidarData\Processed_Data";
Path.WaveData    = "C:\Users\lukec\Desktop\WindLidarData\CalibrationData";
Path.SaveData    = "C:\Users\lukec\Desktop\WindLidarCalibrationAfterpulsingData\CalibrationCurves";
Path.LoadRawData = "C:\Users\lukec\Desktop\DWLandHSRLcode\LoadRawData";
Path.RawData     = "C:\Users\lukec\Desktop\WindLidarData\Raw_Data";

Path.WaveFilename = "20260914_1_46695_21013_22069_60_Cal_Scan_ILX_Wave";
Date_string = "20260914";

Background_start_time = 22+57/60;
Background_end_time   = 23+03/60;

% set the temperature and pressure  
Results.Temperature = linspace(150,350,101); % K
% Results.Temperature = 288.15;
Results.Pressure    = linspace(50,1100,101); % mbar
% Results.Pressure = 1013;

%Constants
c = 299792458; %m/s
L_0 =7.8024635*1e-7; %m, measured by bristol wavemeter
f_0 = c./L_0; % Hz

% Store the home directory
home = pwd;

% Set the user defined options
Bin_width = 250e-9; % s
deadtime = 22e-9;   % s
profiles_per_histogram = 16000; % must match ProfilesPerHist recorded in the MCS files

%% 1.Load Data
% load the data from the thorlabs controller
cd(Path.WaveData)
% load(Path.ThorFilename);

% load the data from the ILX Lightwave controller and the wavemeter
load(Path.WaveFilename);

ILX.Tact     = ILX_Wave_Data.Tact;
ILX.Tact_dt  = ILX_Wave_Data.Tact_dt;
ILX.Iact     = ILX_Wave_Data.Iact;
ILX.Iact_dt  = ILX_Wave_Data.Iact_dt;
ILX.Start_dt = ILX_Wave_Data.Start_dt;
ILX.End_dt   = ILX_Wave_Data.End_dt;

Wave.Lambda    = ILX_Wave_Data.Lambda;
Wave.Lambda_dt = ILX_Wave_Data.Lambda_dt;
Wave.Power     = ILX_Wave_Data.Power;
Wave.Power_dt  = ILX_Wave_Data.Power_dt;

clear ILX_Wave_Data
cd(Path.home)

% load the data from the MCS
[RawData1] = LoadMCS(Date_string,Path);

MCS.Data = [RawData1.Data];
MCS.Time = round([RawData1.time],5);
MCS.ChannelAssignment = RawData1.ChannelAssignment;
MCS.Channel = [RawData1.Channel];

% afterpulsing correction
CR = (MCS.Data)/(Bin_width*profiles_per_histogram);
CF = 1./(1-deadtime*CR);
MCS.Data = MCS.Data.*CF;

clear RawData1 CF CR

%% 2. Put all data onto the same time grid

% convert timestamps to fractional hours since the first ILX.I_act
% timestamp
ILX.I_act_t = zeros(size( ILX.Iact_dt,1),1);
for i = 1:size(ILX.Iact_dt,1)
        ILX.I_act_t(i) = str2double(ILX.Iact_dt(i,13:14))+str2double(ILX.Iact_dt(i,16:17))*1/60+str2double(ILX.Iact_dt(i,19:20))*1/3600;
end

ILX.T_act_t = zeros(size( ILX.Tact_dt,1),1);
for i = 1:size(ILX.Tact_dt,1)
    ILX.T_act_t(i) = str2double(ILX.Tact_dt(i,13:14))+str2double(ILX.Tact_dt(i,16:17))*1/60+str2double(ILX.Tact_dt(i,19:20))*1/3600;
end

ILX.T_start_t = zeros(size( ILX.Tact_dt,1),1);
for i = 1:size(ILX.Tact_dt,1)
    ILX.T_start_t(i) = str2double(ILX.Start_dt(i,13:14))+str2double(ILX.Start_dt(i,16:17))*1/60+str2double(ILX.Start_dt(i,19:20))*1/3600;
end

ILX.T_end_t = zeros(size( ILX.Tact_dt,1),1);
for i = 1:size(ILX.T_end_t,1)
    ILX.T_end_t(i) = str2double(ILX.End_dt(i,13:14))+str2double(ILX.End_dt(i,16:17))*1/60+str2double(ILX.End_dt(i,19:20))*1/3600;
end

Wave.Lambda_t = zeros(size(Wave.Lambda_dt,1),1);
for i = 1:size(Wave.Lambda_dt,1)
    Wave.Lambda_t(i) = str2double(Wave.Lambda_dt(i,13:14))+str2double(Wave.Lambda_dt(i,16:17))*1/60+str2double(Wave.Lambda_dt(i,19:20))*1/3600;
end

Wave.Power_t = zeros(size(Wave.Power_dt,1),1);
for i = 1:size(Wave.Power_dt,1)
    Wave.Power_t(i) = str2double(Wave.Power_dt(i,13:14))+str2double(Wave.Power_dt(i,16:17))*1/60+str2double(Wave.Power_dt(i,19:20))*1/3600;
end

% convert to mW
Wave.Power = 10.^(Wave.Power / 10);

% remove the dateime fields
ILX      = rmfield(ILX     , {'Tact_dt', 'Iact_dt', 'Start_dt', 'End_dt'});
Wave     = rmfield(Wave    , {'Lambda_dt', 'Power_dt'});

% sort data into usable form

% Calculate the number of rows for the new matrix
n = length(Wave.Lambda);
num_rows = n / 5; % 5 = wavemeter readings per wavelength step

% Reshape the vector
Wave.Lambda   = reshape(Wave.Lambda  , 5, num_rows)';
Wave.Lambda_t = reshape(Wave.Lambda_t, 5, num_rows)';
Wave.Power    = reshape(Wave.Power   , 5, num_rows)';
Wave.Power_t  = reshape(Wave.Power_t , 5, num_rows)';

% Take average of wave data
Wave.Lambda   = mean(Wave.Lambda  ,2);
Wave.Lambda_t = mean(Wave.Lambda_t,2);
Wave.Power    = mean(Wave.Power   ,2);
Wave.Power_t  = mean(Wave.Power_t ,2);

% Sort the MCS data
log0 = (MCS.Channel == 0); log0 = (MCS.Channel == 0); % MCS channels: 0 = blue, 1 = red, 2 = combined, 3 = molecular
log1 = (MCS.Channel == 1);
log2 = (MCS.Channel == 2);
log3 = (MCS.Channel == 3);
MCS.Nb = mean(MCS.Data(log0,:) ,2);
MCS.Nr = mean(MCS.Data(log1,:),2);
MCS.Ncom = mean(MCS.Data(log2,:) ,2);
MCS.Nmol = mean(MCS.Data(log3,:),2);
MCS.Nb_t = MCS.Time(log0) ;
MCS.Nr_t = MCS.Time(log1);
MCS.Ncom_t = MCS.Time(log2) ;
MCS.Nmol_t = MCS.Time(log3);

%pull out background counts
ind = MCS.Nb_t > Background_start_time & MCS.Nb_t < Background_end_time;
Bb = mean(MCS.Nb(ind));

ind = MCS.Nr_t > Background_start_time & MCS.Nr_t < Background_end_time;
Br = mean(MCS.Nr(ind));
 
ind = MCS.Ncom_t > Background_start_time & MCS.Ncom_t < Background_end_time;
Bcom = mean(MCS.Ncom(ind));

ind = MCS.Nmol_t > Background_start_time & MCS.Nmol_t < Background_end_time;
Bmol = mean(MCS.Nmol(ind));

MCS.Nb = MCS.Nb - Bb;
MCS.Nr = MCS.Nr - Br;
MCS.Ncom = MCS.Ncom - Bcom;
MCS.Nmol = MCS.Nmol - Bmol;


log0 = zeros(size(MCS.Nb_t));
log1 = zeros(size(MCS.Nr_t));
log2 = zeros(size(MCS.Ncom_t));
log3 = zeros(size(MCS.Nmol_t));

% get rid of data outside of bounds
for i = 1:length(ILX.T_start_t)
    log0(MCS.Nb_t   > ILX.T_start_t(i) & MCS.Nb_t   < ILX.T_end_t(i)) = 1;
    log1(MCS.Nr_t   > ILX.T_start_t(i) & MCS.Nr_t   < ILX.T_end_t(i)) = 1;
    log2(MCS.Ncom_t > ILX.T_start_t(i) & MCS.Ncom_t < ILX.T_end_t(i)) = 1;
    log3(MCS.Nmol_t > ILX.T_start_t(i) & MCS.Nmol_t < ILX.T_end_t(i)) = 1;
end



% trim the data
t_low  = ILX.T_start_t(1);
t_high = ILX.T_end_t(end);

ind = (Wave.Lambda_t>=t_low & Wave.Lambda_t<=t_high);
Wave.Lambda(~ind) = [];
Wave.Lambda_t(~ind) = [];

ind = (Wave.Power_t >=t_low & Wave.Power_t <=t_high);
Wave.Power(~ind) = [];
Wave.Power_t(~ind) = [];

ind = (MCS.Nb_t>=t_low & MCS.Nb_t<=t_high);
MCS.Nb(~ind) = [];
MCS.Nb_t(~ind) = [];

ind = (MCS.Nr_t>=t_low & MCS.Nr_t<=t_high);
MCS.Nr(~ind) = [];
MCS.Nr_t(~ind) = [];

ind = (MCS.Ncom_t>=t_low & MCS.Ncom_t<=t_high);
MCS.Ncom(~ind) = [];
MCS.Ncom_t(~ind) = [];

ind = (MCS.Nmol_t>=t_low & MCS.Nmol_t<=t_high);
MCS.Nmol(~ind) = [];
MCS.Nmol_t(~ind) = [];

log0 = zeros(size(MCS.Nb_t));
log1 = zeros(size(MCS.Nr_t));
log2 = zeros(size(MCS.Ncom_t));
log3 = zeros(size(MCS.Nmol_t));

% get rid of data outside of bounds
for i = 1:length(ILX.T_start_t)
    log0(MCS.Nb_t   > ILX.T_start_t(i) & MCS.Nb_t   < ILX.T_end_t(i)) = 1;
    log1(MCS.Nr_t   > ILX.T_start_t(i) & MCS.Nr_t   < ILX.T_end_t(i)) = 1;
    log2(MCS.Ncom_t > ILX.T_start_t(i) & MCS.Ncom_t < ILX.T_end_t(i)) = 1;
    log3(MCS.Nmol_t > ILX.T_start_t(i) & MCS.Nmol_t < ILX.T_end_t(i)) = 1;
end

MCS.Nb(~log0)     = [];
MCS.Nb_t(~log0)   = [];
MCS.Nr(~log1)     = [];
MCS.Nr_t(~log1)   = [];
MCS.Ncom(~log2)   = [];
MCS.Ncom_t(~log2) = [];
MCS.Nmol(~log3)   = [];
MCS.Nmol_t(~log3) = [];

MCS = rmfield(MCS,{'Data', 'Time', 'ChannelAssignment', 'Channel'});


clear i ind log 0 log1 log2 log3 n num_rows t_high t_low day_index

% Put Data observations on the same timegrid as the wavelength observations

t = Wave.Lambda_t;
L = Wave.Lambda*1e-9;
P = Wave.Power;

Nb_old = MCS.Nb;
Nb_t   = MCS.Nb_t;
Nr_old = MCS.Nr;
Nr_t   = MCS.Nr_t;

Nmol_old = MCS.Nmol;
Nmol_t   = MCS.Nmol_t;
Ncom_old = MCS.Ncom;
Ncom_t   = MCS.Ncom_t;

Nb_t_ind = zeros(length(Nb_t),1);
for i = 1:length(Nb_t)
    [~, idx] = min(abs(t - Nb_t(i)));
    Nb_t_ind(i) = idx;
end

Nr_t_ind = zeros(length(Nr_t),1);
for i = 1:length(Nr_t)
    [~, idx] = min(abs(t - Nr_t(i)));
    Nr_t_ind(i) = idx;
end

Nmol_t_ind = zeros(length(Nmol_t),1);
for i = 1:length(Nmol_t)
    [~, idx] = min(abs(t - Nmol_t(i)));
    Nmol_t_ind(i) = idx;
end

Ncom_t_ind = zeros(length(Ncom_t),1);
for i = 1:length(Ncom_t)
    [~, idx] = min(abs(t - Ncom_t(i)));
    Ncom_t_ind(i) = idx;
end

Nb = zeros(size(t));
Nr = zeros(size(t));
Nmol = zeros(size(t));
Ncom = zeros(size(t));

for i=1:length(t)

    Nb(i) = mean(Nb_old(Nb_t_ind == i & Nb_old~=0));
    Nr(i) = mean(Nr_old(Nr_t_ind == i & Nr_old~=0));
    Nmol(i) = mean(Nmol_old(Nmol_t_ind == i & Nmol_old~=0));
    Ncom(i) = mean(Ncom_old(Ncom_t_ind == i & Ncom_old~=0));

end

Nb = smoothdata(Nb,'sgolay',10);
Nr = smoothdata(Nr,'sgolay',10);
Nmol = smoothdata(Nmol,'sgolay',10);
Ncom = smoothdata(Ncom,'sgolay',10);

% normalize the power to the max observed power
P = P./max(P);

% normalize counts to power

Wave.Nb_P = Nb./P;
Wave.Nr_P = Nr./P;
Wave.Ncom_P = Ncom./P;
Wave.Nmol_P = Nmol./P;
Wave.Lambda = Wave.Lambda*1e-9;

% clear extra variables
clear Nb Nb_old Nb_t Nb_t_ind Ncom Ncom_old Ncom_t Ncom_t_ind Nmol...
      Nmol_old Nmol_t Nmol_t_ind Nr Nr_old Nr_t Nr_t_ind Options i idx 

%% 3. Create a uniform frequency grid and interpolate data to this grid
f = c./Wave.Lambda;
f_span = min([abs(c./L_0 - f(1)),abs(c./L_0 - f(end))]);
f_shift = (-floor(f_span/1e8)*1e8:1e7:floor(f_span/1e8)*1e8);

% sort by ascending frequency
[~,I] = sort(f);
f = f(I);
Nb =   Wave.Nb_P(I);
Nr =   Wave.Nr_P(I);
Ncom = Wave.Ncom_P(I);
Nmol = Wave.Nmol_P(I);

% combine non-unique points
[~, I_unique] = unique(f);
I_dup = setdiff(1:numel(f), I_unique);

dup_vals = f(I_dup);
for i = 1:numel(dup_vals)
    I_group = find(f == dup_vals(i));
    I_first = I_group(1);
    Nb(I_first)   = mean(Nb(I_group));
    Nr(I_first)   = mean(Nr(I_group));
    Ncom(I_first) = mean(Ncom(I_group));
    Nmol(I_first) = mean(Nmol(I_group));
    P(I_first)    = mean(P(I_group));
end

% delete duplicate indices
f(I_dup)    = [];
Nb(I_dup)   = [];
Nr(I_dup)   = [];
Ncom(I_dup) = [];
Nmol(I_dup) = [];
P(I_dup)    = [];
t(I_dup)    = [];

% interpolate the wavelength data to match the frequency grid
Freq.f_shift = f_shift;
Freq.f = f_0 + f_shift;

Freq.Nb_P   = interp1(f,Nb,Freq.f);
Freq.Nr_P   = interp1(f,Nr,Freq.f);
Freq.Ncom_P = interp1(f,Ncom,Freq.f);
Freq.Nmol_P = interp1(f,Nmol,Freq.f);

clear f f_span f_shift I Nb Nr Ncom Nmol I_unique dup_vals I_dup

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HSRL different than DWL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% from this point on

%% 4. Convert the counts to transmission functions

ind = max(Freq.Ncom_P);

Freq.Tcom = Freq.Ncom_P./ind;
Freq.Tmol = Freq.Nmol_P./ind;


%% 5. Double nested for loop to determine Calibration constants
Results.Cmm=zeros(length(Results.Temperature),length(Results.Pressure));
Results.Cmc=zeros(length(Results.Temperature),length(Results.Pressure));
Results.Cam=zeros(length(Results.Temperature),length(Results.Pressure));
Results.Cac=zeros(length(Results.Temperature),length(Results.Pressure));

% load in the principal components outside of the for loop
% navigate to the directory containing the principal component analysis data
cd("C:\Users\lukec\Desktop\HSRLCalibrationAfterpulsing\CabannesPCA")

%load the PCA data
load("PCA780_2465nm_7_5GHz_20.mat")

% navigate to the home directory
cd(home)

% navigate to the code containing the calibration constant code
cd("CalibrationConstantCode")

% wavelength
tic
%temperature
for i = 1:length(Results.Temperature)
    disp(append("i = ",num2str(i),"/",num2str(length(Results.Temperature))))
    
    %pressure
    for j = 1:length(Results.Pressure)
        
        %% 5.1 Find Cam and Cac
        % This section of code finds the aerosol efficiency through the
        % molecular and combined channel

        % function that finds Cam and Cac
        [Results] = FindCamCac(Results,Freq,i,j);

        %% 5.2 Create Cabannes profile
        % This section of code generates the Cabannes profile using the
        % principal components

        % function that calls the PCA code to generate the Cabbanes
        % spectrum
        [Cabannes] = CreateCabannesSpectrum(PCA,Results,Freq,i,j);

        %% 5.3 Find Cmm and Cmc
        % This section of code finds the molecular efficiency through
        % the combined and molecular channels

        % function that finds Cmm and Cmc
        [Results] = FindCmmCmc(Results,Freq,Cabannes,i,j);

        %% 5.4 Normalize the calibration constants so that Cac = 1
        % This section of code normalizes the calibration constants so
        % that Cac = 1
        
        % function that normalizes the calibration constants so that
        % Cac = 1
        [Results] = NormalizeCalibrationConstants(Results,i,j);
    end
    
end

toc
% navigate home
cd(home)

%% 6. Plotting
%This function creates the plots

%navigate to the folder that contains the plotting code
cd("PlottingCode")

disp("Plotting")

%function that plots the scans as a count rate

% function that plots Nc/Nm

% function that plots the etalon, potassium cell, and etalon + potassium
% cell transmission

%function that plots the molecular and combined channel transmission

% function that plots the molecular scattering spectrum at 20C and 1 atm vs
% the molecular and combined channel transmissions

% function that plots an image of Cmm and Cmc vs the temperature and
% pressure
CreateCmmCmcImage(Results,Freq)

% navigate back to the home folder
cd(home)


%% 7. Saving Data 

% create a filename
filename = Date_string;

% navigate to the folder that contains the calibration scans
cd("C:\Users\lukec\Desktop\HSRLCalibrationAfterpulsing\CalibrationTables")

Results.Cam(Results.Cam<0) = nan;
Results.Cam(isnan(Results.Cam)) = mean(mean(mean(Results.Cam,'omitnan'),'omitnan'),'omitnan');
% save the data
save(append(filename,"_calibration.mat"),'Results')

% navigate home
cd(home)