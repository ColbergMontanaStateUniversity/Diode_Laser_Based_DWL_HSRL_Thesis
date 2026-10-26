function [RawData] = TrimAndSortAfterpulsing(RawData,Date)
% this function trims and sorts the MCS data
% it deletes any data from before the start time or after the end time and
% sorts the data from the 4 channels

%% Trim the data
% find the indices where the time is outside of the start and end times
logind = (RawData.MCS.time < Date.starttime) | (RawData.MCS.time > Date.endtime);

% delete data outside of that range
RawData.MCS.time(logind)            = [];
RawData.MCS.ProfilesPerHist(logind) = [];
RawData.MCS.Channel(logind)         = [];
RawData.MCS.nsPerBin(logind)        = [];
RawData.MCS.NBins(logind)           = [];
RawData.MCS.Data(logind,:)          = [];
RawData.MCS.RTime(logind)           = [];
RawData.MCS.FrameCount(logind)      = [];
RawData.MCS.SyncSource(logind)      = [];

% clear unnecessary variables
clear logind

%% Sort the data

% Begin by finding the indices of each channel
% The channel naming scheme is an artifact of using the NCAR HSRL labview
% control program to run the combined DWL and HSRL. May need to change.
RawData.MCS.BlueChannel = find(strcmp(RawData.MCS.ChannelAssignment,'HSRLMol'     ))-1; % -1 to convert from base 1 to base 0
RawData.MCS.RedChannel  = find(strcmp(RawData.MCS.ChannelAssignment,'HSRLMolLow'))-1;
RawData.MCS.CombinedChannel = find(strcmp(RawData.MCS.ChannelAssignment,'HSRLCombined'     ))-1;
RawData.MCS.MolecularChannel  = find(strcmp(RawData.MCS.ChannelAssignment,'HSRLCombinedLow'))-1;

% create a logical operator for each channel assignment
IndexBlue = (RawData.MCS.Channel==RawData.MCS.BlueChannel);
IndexRed  = (RawData.MCS.Channel==RawData.MCS.RedChannel );
IndexCom  = (RawData.MCS.Channel==RawData.MCS.CombinedChannel);
IndexMol  = (RawData.MCS.Channel==RawData.MCS.MolecularChannel );

% sort the data into the 4 component signals
RawData.MCS.BlueData = RawData.MCS.Data(IndexBlue,:);
RawData.MCS.RedData  = RawData.MCS.Data(IndexRed ,:);
RawData.MCS.CombinedData = RawData.MCS.Data(IndexCom,:);
RawData.MCS.MolecularData  = RawData.MCS.Data(IndexMol ,:);

% sort the time into the 4 component signals
RawData.MCS.BlueTime = RawData.MCS.time(IndexBlue,:);
RawData.MCS.RedTime  = RawData.MCS.time(IndexRed ,:);
RawData.MCS.CombinedTime = RawData.MCS.time(IndexCom,:);
RawData.MCS.MolecularTime  = RawData.MCS.time(IndexMol ,:);

% store the indices
RawData.MCS.IndexBlue_Log = IndexBlue;
RawData.MCS.IndexRed_Log  = IndexRed ;
RawData.MCS.IndexCombined_Log = IndexCom;
RawData.MCS.IndexMolecular_Log  = IndexMol;

end