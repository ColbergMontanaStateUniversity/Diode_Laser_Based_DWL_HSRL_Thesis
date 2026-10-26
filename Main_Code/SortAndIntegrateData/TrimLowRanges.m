function [RawData] = TrimLowRanges(RawData,Options)
% This function sets data below Options.low_bin to NaN

% find the low range index
ind = Options.low_bin;

% turn data from ranges 1:ind-1 to NaN
RawData.MCS.BlueData(:,1:ind-1) = NaN;
RawData.MCS.RedData (:,1:ind-1) = NaN;
RawData.MCS.CombinedData(:,1:ind-1) = NaN;
RawData.MCS.MolecularData(:,1:ind-1) = NaN;

%clear unnecessary variables
clear ind

end