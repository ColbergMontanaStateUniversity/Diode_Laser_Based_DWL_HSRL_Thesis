function [Counts] = BackgroundSubtraction(Counts)
% this function subtracts the background using an estimation of the
% background from the last 50 range bins

% find the background
BackgroundBlueData = mean(Counts.BlueData(end-49:end)); % hardcoded last 50 bins to find background
BackgroundRedData  = mean(Counts.RedData (end-49:end));
BackgroundCombinedData = mean(Counts.CombinedData(end-49:end));
BackgroundMolecularData  = mean(Counts.MolecularData (end-49:end));

% subtract the background
Counts.BlueData = Counts.BlueData - BackgroundBlueData;
Counts.RedData  = Counts.RedData  - BackgroundRedData ;
Counts.CombinedData = Counts.CombinedData - BackgroundCombinedData;
Counts.MolecularData  = Counts.MolecularData  - BackgroundMolecularData ;

end