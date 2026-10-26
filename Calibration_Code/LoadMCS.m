function [MCS] = LoadMCS(foldername,Path)
% this function extracts the MCS netCDF files from the raw data folder

% Expects files named MCS*.nc in Path.RawData/<foldername>/, where
% foldername is the date string (YYYYMMDD). Files are read with h5read,
% so they must be netCDF-4 (HDF5-based) files.

% inputs
% foldername - a string containing the name of the folder that contains
% the netCDF files
% Path - a structure containing the file paths

% outputs
% MCS -  a structure containing the data stored in the UPS netCDF files
% containing the following variables:
% MCS.time -  The time of collected data in UTC hours from the start of the
% day in fractional hours
% MCS.ProfilesPerHist - Number of laser shots summed to create a single
% verticle histogram
% MCS.Channel - MCS hardware channel number for each measurement. There are
% 8 real valued inputs and 4 extra channels resulting from demuxing
% MCS.nsPerBin - The width of each altitude bin in ns
% MCS.NBins - Number of sequential altitude bins measured for each
% histogram profile
% MCS.Data - A profile containing the number of photons returned
% in each of the sequential altitude bin 
% MCS.ChannelAssignment - String value defining what hardware was connected
% to the MCS digital detection channels (Choices are: WVOnline, WVOffline,
% HSRLCombined, HSRLMolecular, O2Online, O2Offline, or Unassigned)
% MCS.RTime - Relative time counter, 20 bit time valuerelative to the most
% recent system reset (or time reset)
% MCS.FrameCount - Number of the data frame sent by the MCS. This should be
% sequential and incrimenting by 1 each new measurement
% MCS.SyncSource - The number of the input sync source used on the MCS.
% There are 3 availible numbered 0-2.




% store the current folder as a variable
home = pwd;

%navigate to the folder containing the raw data
cd(Path.RawData)
cd(foldername)

%create a directory of the pertinent files
Directory = dir('MCS*.nc');

% load in the time through concatenation
MCS.time = [];
for i = 1:length(Directory)
    MCS.time =[MCS.time;h5read(Directory(i).name,'/time')];
end

% load in the channel assignment
MCS.ChannelAssignment = h5read(Directory(1).name,'/ChannelAssignment');
NBins  = h5read(Directory(1).name,'/NBins');
MCS.nBins = NBins(1);

%preallocate the other variables
MCS.ProfilesPerHist = zeros(size(MCS.time),'single');
MCS.Channel = zeros(size(MCS.time),'single');
MCS.nsPerBin = zeros(size(MCS.time),'single');
MCS.NBins = zeros(size(MCS.time),'single');
MCS.Data = zeros(length(MCS.time),MCS.nBins,'single');
MCS.RTime = zeros(size(MCS.time),'single');
MCS.FrameCount = zeros(size(MCS.time),'single');
MCS.SyncSource = zeros(size(MCS.time),'single');

%load through a counter and a for loop
counter=1;
for i=1:length(Directory)

    ProfilesPerHist  = h5read(Directory(i).name,'/ProfilesPerHist');
    MCS.ProfilesPerHist (counter:counter+length(ProfilesPerHist)-1,:)  = ProfilesPerHist;
        
    Channel  = h5read(Directory(i).name,'/Channel');
    MCS.Channel (counter:counter+length(Channel)-1,:)  = Channel;
        
    nsPerBin  = h5read(Directory(i).name,'/nsPerBin');
    MCS.nsPerBin (counter:counter+length(nsPerBin)-1,:)  = nsPerBin;

    NBins  = h5read(Directory(i).name,'/NBins');
    MCS.NBins (counter:counter+length(NBins)-1,:)  = NBins;
        
    Data  = h5read(Directory(i).name,'/Data');
    MCS.Data (counter:counter+length(Data(:,1))-1,:)  = Data;    
        
    RTime  = h5read(Directory(i).name,'/RTime');
    MCS.RTime (counter:counter+length(RTime)-1,:)  = RTime;
        
    FrameCount  = h5read(Directory(i).name,'/FrameCount');
    MCS.FrameCount (counter:counter+length(FrameCount)-1,:)  = FrameCount;
        
    SyncSource  = h5read(Directory(i).name,'/SyncSource');
    MCS.SyncSource (counter:counter+length(SyncSource)-1,:)  = SyncSource;

    counter = counter+length(ProfilesPerHist);
end
   
% clear unnecessary variables
clear Directory ProfilesPerHist Channel  nsPerBin  NBins Data  RTime  ...
    FrameCount SyncSource counter i

% navigate back to the home folder
cd(home)

end