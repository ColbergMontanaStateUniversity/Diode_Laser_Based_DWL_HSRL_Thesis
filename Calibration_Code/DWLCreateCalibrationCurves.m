% Generates the receiver transmission curves (blue, red, combined, and
% molecular channels) from a laser frequency calibration scan.
%
% Inputs:
%   - ILX/wavemeter scan file (Path.WaveFilename) located in Path.WaveData
%   - MCS netCDF files located in Path.RawData/<Date_string>/
% Output (saved to Path.SaveData as <Date_string>_Curves.mat):
%   freqhz - frequency shift from L_0 (Hz)
%   Tblue, Tred, Tmol, Tcom - normalized channel transmissions
%
% Run from the folder containing this script. LoadMCS.m must be in the
% same folder or on the MATLAB path.

clear all; close all;

%% 0.Pre-code

%define Paths
Path.home = pwd;
Path.MCSData  = "C:\Users\lukec\Desktop\WindLidarData\Processed_Data";
Path.WaveData = "C:\Users\lukec\Desktop\WindLidarData\CalibrationData";
Path.SaveData = "C:\Users\lukec\Desktop\WindLidarCalibrationAfterpulsingData\CalibrationCurves";

Path.WaveFilename = "20260914_1_46695_21013_22069_60_Cal_Scan_ILX_Wave";
Date_string = "20260914";

Background_start_time = 22+57/60; % UTC, fractional hours
Background_end_time   = 23+03/60;


Path.LoadRawData = 'C:\Users\lukec\Desktop\DWLandHSRLcode\LoadRawData';
Path.RawData    = 'C:\Users\lukec\Desktop\WindLidarData\Raw_Data';

%Constants
L_0 =7.8024635*1e-7; %m, measured by bristol wavemeter
c = 299792458; %m/s

% user-defined options
Bin_width = 250e-9; % s
deadtime = 22e-9;   % s
profiles_per_histogram = 8000; % must match ProfilesPerHist recorded in the MCS files

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
CR = (MCS.Data)/(Bin_width*2*profiles_per_histogram);
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



%% 3. sort data into usable form

% Calculate the number of rows for the new matrix
n = length(Wave.Lambda);
num_rows = n / 5; % 5 = wavemeter readings per wavelength step

% Reshape the vector
Wave.Lambda   = reshape(Wave.Lambda  , 5, num_rows)';
Wave.Lambda_t = reshape(Wave.Lambda_t, 5, num_rows)';
Wave.Power    = reshape(Wave.Power   , 5, num_rows)';
Wave.Power_t  = reshape(Wave.Power_t , 5, num_rows)';

% Take average of wave data
Wave.Lambda   = mean(Wave.Lambda  ,2,'omitnan');
Wave.Lambda_t = mean(Wave.Lambda_t,2,'omitnan');
Wave.Power    = mean(Wave.Power   ,2,'omitnan');
Wave.Power_t  = mean(Wave.Power_t ,2,'omitnan');

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

%% 4. Put Data observations on the same timegrid as the wavelength observations

t = Wave.Lambda_t;
L = Wave.Lambda*1e-9;
I = ILX.Iact';

P = Wave.Power;
% % % % % % load("C:\Users\lukec\Desktop\DWLandHSRLcode\Calibration\BOA_100mA_model.mat");
% % % % % % 
% % % % % % P = p(1)*I.^2 + p(2)*I + p(3);

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


% normalize the power to the max observed power
P = P./max(P);

% normalize counts to power

Nb_P = Nb./P;
Nr_P = Nr./P;
Ncom_P = Ncom./P;
Nmol_P = Nmol./P;

fig1 = figure(1); 
p(1) = plot(t - t(1),Nb./(Bin_width*2*profiles_per_histogram)/1e6,'-b');
hold on; 
p(2) = plot(t - t(1),Nr./(Bin_width*2*profiles_per_histogram)/1e6,'-r');
p(3) = plot(t - t(1),Ncom./(Bin_width*2*profiles_per_histogram)/1e6,'-m');
p(4) = plot(t - t(1),Nmol./(Bin_width*2*profiles_per_histogram)/1e6,'-k');

grid on
ylabel('Count rate (MHz)')
xlabel('Time since start of scan (Hours)')
legend([p(1) p(2) p(3) p(4)],'N_b','N_r','N_{com}','N_{mol}','Location','Best')
set(gca,'FontSize',12)
set(gca, 'FontName', 'Times New Roman')

% sort by ascending wavelength
[L, indices] = sort(L);

Nb_P = Nb_P(indices);
Nr_P = Nr_P(indices);
Ncom_P = Ncom_P(indices);
Nmol_P = Nmol_P(indices);
P = P(indices);

%smoothdata
Nb_P = smoothdata(Nb_P,'g',5);
Nr_P = smoothdata(Nr_P,'g',5);


fig2 = figure(2); 
p(1) = plot(L*1e9,Nb_P./(Bin_width*2*profiles_per_histogram)/1e6,'--b');
hold on; 
p(2) = plot(L*1e9,Nr_P./(Bin_width*2*profiles_per_histogram)/1e6,'-r');
p(3) = xline(780.24635,':k');

grid on
ylabel('Count rate (MHz)')
xlabel('Wavelength (nm)')
legend([p(1) p(2)],'N_b','N_r','Location','Best')
set(gca,'FontSize',12)
set(gca, 'FontName', 'Times New Roman')

a = 0.010; xlim([780.24635-a 780.24635+a]);


Ncom_P = smoothdata(Ncom_P,'movmean',5);
Nmol_P = smoothdata(Nmol_P,'movmean',5);

fig3 = figure(3); 
p(1) = plot(L*1e9,Nb_P./(Bin_width*2*profiles_per_histogram)/1e6,'--b');
hold on; 
p(2) = plot(L*1e9,Nr_P./(Bin_width*2*profiles_per_histogram)/1e6,'-r');
p(3) = plot(L*1e9,Ncom_P./(Bin_width*2*profiles_per_histogram)/1e6,':g');
p(4) = plot(L*1e9,Nmol_P./(Bin_width*2*profiles_per_histogram)/1e6,'-.m');
p(5) = xline(780.24635,'k');

grid on
ylabel('Count rate (MHz)')
xlabel('Wavelength (nm)')
legend([p(1) p(2) p(3) p(4) p(5)],'N_b','N_r','N_{com}','N_{mol}','780.24635 nm','Location','Best')
set(gca,'FontSize',12)
set(gca, 'FontName', 'Times New Roman')

a = 0.0075; xlim([780.24635-a 780.24635+a]);

fig4 = figure(4); 
p(1) = plot(L*1e9,Nmol_P./(Bin_width*2*profiles_per_histogram)/1e6,'--r');
hold on; 
p(2) = plot(L*1e9,Ncom_P./(Bin_width*2*profiles_per_histogram)/1e6,'-b');
p(3) = xline(780.24635,':k');

grid on
ylabel('Count rate (MHz)')
xlabel('Wavelength (nm)')
legend([p(1) p(2)],'N_{mol}','N_{com}','Location','Best')
set(gca,'FontSize',12)
set(gca, 'FontName', 'Times New Roman')

a = 0.010; xlim([780.24635-a 780.24635+a]);

% normalize to the maximum counts
M = max([max(Nb_P) max(Nr_P)]);
Nb_P = Nb_P./M;
Nr_P = Nr_P./M;

M = max([max(Ncom_P) max(Nmol_P)]);
Ncom_P = Ncom_P./M;
Nmol_P = Nmol_P./M;

fig5 = figure(5); 
plot(L,Nb_P,'bs'); 
hold on; 
plot(L,Nr_P,'rd'); 
xline(L_0,'--k')

fig6 = figure(6); 
plot(L,Nmol_P,'rs'); 
hold on; 
plot(L,Ncom_P,'bd'); 
xline(L_0,'--k')

fig7 = figure(7);
plot(L,Nmol_P./Ncom_P); 
hold on;
xline(L_0,'--k')


% delete repeated points

[L,I] = unique(L);
Nb_P   = Nb_P(I);
Nr_P   = Nr_P(I);
Nmol_P = Nmol_P(I);
Ncom_P = Ncom_P(I);
P = P(I);

% convert to frequency

nu_0 = c./L_0;
nu   = c./L  ;

nu_shift_old = nu - nu_0;
nu_shift = linspace(-7.5e9,7.5e9,10001);

% sort by ascending
[nu_shift_old,I] = sort(nu_shift_old,'ascend');
Ncom_P = Ncom_P(I);
Nmol_P = Nmol_P(I);
Nr_P   = Nr_P(I);
Nb_P   = Nb_P(I);

% delete repeated points
[nu_shift_old,I] = unique(nu_shift_old);
Nmol_P = Nmol_P(I);
Ncom_P = Ncom_P(I);  
Nr_P = Nr_P(I);
Nb_P = Nb_P(I);  

Ncom_P = interp1(nu_shift_old,Ncom_P,nu_shift);
Nmol_P = interp1(nu_shift_old,Nmol_P,nu_shift);
Nr_P = interp1(nu_shift_old,Nr_P,nu_shift);
Nb_P = interp1(nu_shift_old,Nb_P,nu_shift);

%Store the recevier scans
freqhz = nu_shift;
Tblue  = Nb_P;
Tred   = Nr_P;
Tmol   = Nmol_P;
Tcom   = Ncom_P;

% Save data
cd(Path.SaveData)
save(strcat(Date_string,'_Curves.mat'), 'freqhz', 'Tblue', 'Tred','Tmol','Tcom');
cd(Path.home)
