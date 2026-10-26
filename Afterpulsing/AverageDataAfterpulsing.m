function [Counts] = AverageDataAfterpulsing(RawData)
% this function takes the profiles from the RawData structure and
% averages them into a single profile

%average the data
Counts.BlueData       = mean(RawData.MCS.BlueData     ,1);
Counts.RedData        = mean(RawData.MCS.RedData      ,1);
Counts.CombinedData   = mean(RawData.MCS.CombinedData ,1);
Counts.MolecularData  = mean(RawData.MCS.MolecularData,1);

end