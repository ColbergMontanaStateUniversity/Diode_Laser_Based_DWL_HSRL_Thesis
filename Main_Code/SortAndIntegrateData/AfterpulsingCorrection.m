function [RawData] = AfterpulsingCorrection(RawData,Path,Options)
% This function corrects for the afterpulsing in the avalanche photodiodes
% by subtracting a measured profile taken when the lidar was blocked

% assumes that the bin settings were the same during the afterpulsing
% measurements as during the data  being collected

% store the current directory
home = pwd;

% navigate to the folder containing the afterpulsing data
cd(Path.AfterpulsingData)

% load the afterpulsing data
load(Options.Afterpulsing_filename)

% create arrays from the afterpulsing data using repmats that are the same
% size as the RawData arrays
Ab = repmat(Afterpulsing.BlueData     ,size(RawData.MCS.BlueData     ,1),1);
Ar = repmat(Afterpulsing.RedData      ,size(RawData.MCS.RedData      ,1),1);
Ac = repmat(Afterpulsing.CombinedData ,size(RawData.MCS.CombinedData ,1),1);
Am = repmat(Afterpulsing.MolecularData,size(RawData.MCS.MolecularData,1),1);

%perform the subtraction
RawData.MCS.BlueData = RawData.MCS.BlueData - Ab;
RawData.MCS.RedData  = RawData.MCS.RedData  - Ar;
RawData.MCS.CombinedData  = RawData.MCS.CombinedData  - Ac;
RawData.MCS.MolecularData = RawData.MCS.MolecularData - Am;

% navigate back to the home directory
cd(home)

end