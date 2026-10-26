function [RawData] = SortData(RawData)
% This function goes through the RawData structure and sorts the data into
% the counts associated with each laser and detector

%% Sort the data from the MCS
% Begin by finding the indices of each channel
RawData.MCS.BlueChannel = find(strcmp(RawData.MCS.ChannelAssignment,'HSRLMol'     ))-1;
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