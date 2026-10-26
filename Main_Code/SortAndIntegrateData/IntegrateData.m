function [Counts] = IntegrateData(RawData,Options,Constants)
% This function integrates the raw data from the netCDF file into bins of
% the specified range and time widths

%% Integration in time
% convert the time step into fractional hours
dt = Options.time_step/60;

% create the time vector for the Counts structure
Counts.time=floor(RawData.MCS.time(1))+dt/2:dt:ceil(max(RawData.MCS.time))-dt/2;

% create two vectors which mark the upper and lower limits of the time that
% falls into each bin of the Counts.time vector
time_low  = floor(RawData.MCS.time(1))   :dt:ceil(max(RawData.MCS.time))-dt;
time_high = floor(RawData.MCS.time(1))+dt:dt:ceil(max(RawData.MCS.time))   ;

% preallocate the arrays for the integrated data
Nb = NaN(RawData.MCS.nBins,length(Counts.time));
Nr = NaN(RawData.MCS.nBins,length(Counts.time));
Nc = NaN(RawData.MCS.nBins,length(Counts.time));
Nm = NaN(RawData.MCS.nBins,length(Counts.time));

PPHb = NaN(1,length(Counts.time));
PPHr = NaN(1,length(Counts.time));
PPHc = NaN(1,length(Counts.time));
PPHm = NaN(1,length(Counts.time));

% move variables from structure to local
BD = RawData.MCS.BlueData ;
RD = RawData.MCS.RedData;
CD = RawData.MCS.CombinedData ;
MD = RawData.MCS.MolecularData;

BT = RawData.MCS.BlueTime ;
RT = RawData.MCS.RedTime;
CT = RawData.MCS.CombinedTime ;
MT = RawData.MCS.MolecularTime;

% for loop that adds up all the profiles that fall in time bin set by
% Options.time_step
for i=1:length(Counts.time)

    % the four following groups of code follow the structure:
    % 1. Find the indices of the time bins which will be integrated into
    % the ith time bin and create a logical operator
    % 2. Store these counts as a temporary variable
    % 3. Sum these counts and store them in the Number of photons variables
    % 4. Sum the logical operator and store it in the PPH variable. This is
    % the number of histograms summed into the ith time bin, not the
    % number of laser shots. The number of laser shots is
    % PPH * RawData.MCS.ProfilesPerHist.

    tempind = (BT >= time_low(i) & BT < time_high(i));
    tempNb  = BD(tempind,:);
    Nb(:,i) = sum(tempNb,1);
    PPHb(i) = sum(tempind);

    tempind = (RT >= time_low(i) & RT < time_high(i));
    tempNr  = RD(tempind,:);
    Nr(:,i) = sum(tempNr,1);
    PPHr(i) = sum(tempind);

    tempind = (CT >= time_low(i) & CT < time_high(i));
    tempNc  = CD(tempind,:);
    Nc(:,i) = sum(tempNc,1);
    PPHc(i) = sum(tempind);

    tempind = (MT >= time_low(i) & MT < time_high(i));
    tempNm  = MD(tempind,:);
    Nm(:,i) = sum(tempNm,1);
    PPHm(i) = sum(tempind);
end


% store Number of photons and ProfilesPerHist in Counts vector
Counts.Nb = Nb;
Counts.Nr = Nr;
Counts.Nc = Nc;
Counts.Nm = Nm;

% store the number of histograms summed into each time bin
% (multiply by RawData.MCS.ProfilesPerHist for the number of laser shots)
Counts.PPHb = PPHb;
Counts.PPHr = PPHr;
Counts.PPHc = PPHc;
Counts.PPHm = PPHm;

%% Integration in range
% determine the range step 
dr = Options.range_step*Options.Bin_width*Constants.c/2;

% determine the range of the lowest bin
r_low = dr/2-(Options.Pulse_length/2-Options.Sync_delay+Options.TSOA_delay)*Constants.c/2;

%create a range vector
r = (r_low:dr:r_low+(RawData.MCS.nBins/Options.range_step-1)*dr)';

% if statement that performs range integration only if the
% Options.range_step > 1 bin

if Options.range_step > 1 

    % convert the time-integrated counts to a local variable
    Nb_old = Counts.Nb;
    Nr_old = Counts.Nr;
    Nc_old = Counts.Nc;
    Nm_old = Counts.Nm;

    %create two vectors for the upper and lower range bins to be included
    range_low  = (1:Options.range_step:length(r)*Options.range_step-1);
    range_high = (Options.range_step:Options.range_step:length(r)*Options.range_step);

    % preallocate the arrays for the integrated data
    Nb = NaN(length(range_low),length(Counts.time));
    Nr = NaN(length(range_low),length(Counts.time));
    Nc = NaN(length(range_low),length(Counts.time));
    Nm = NaN(length(range_low),length(Counts.time));
  
    %for loop to integrate over range
    for i = 1 : length(range_low)
        
        % sum the data from the old counts array into the new range bin
        Nb(i,:) = sum(Nb_old(range_low(i):range_high(i),:),1);
        Nr(i,:) = sum(Nr_old(range_low(i):range_high(i),:),1);
        Nc(i,:) = sum(Nc_old(range_low(i):range_high(i),:),1);
        Nm(i,:) = sum(Nm_old(range_low(i):range_high(i),:),1);

    end

    % overwrite the data in the Counts structure
    Counts.Nb = Nb;
    Counts.Nr = Nr;
    Counts.Nc = Nc;
    Counts.Nm = Nm;

end

% store the range vector in the Counts structure
Counts.range = r;

end