function [RawData] = PhotonCountingCorrection(RawData,Options)
% this function corrects for nonlinear effects caused by photon counting

%create variables of the count rate for each of the 4 channels
CR_b = RawData.MCS.BlueData/(RawData.MCS.ProfilesPerHist(1)*Options.Bin_width);
CR_r = RawData.MCS.RedData /(RawData.MCS.ProfilesPerHist(1)*Options.Bin_width);
CR_c = RawData.MCS.CombinedData/(RawData.MCS.ProfilesPerHist(1)*Options.Bin_width);
CR_m = RawData.MCS.MolecularData /(RawData.MCS.ProfilesPerHist(1)*Options.Bin_width);

% determine the correction factor
CF_b = 1./(1-Options.APD_deadtime*CR_b);
CF_r = 1./(1-Options.APD_deadtime*CR_r);
CF_c = 1./(1-Options.APD_deadtime*CR_c);
CF_m = 1./(1-Options.APD_deadtime*CR_m);

% correct the data
RawData.MCS.BlueData = RawData.MCS.BlueData .* CF_b;
RawData.MCS.RedData  = RawData.MCS.RedData  .* CF_r;
RawData.MCS.CombinedData = RawData.MCS.CombinedData .* CF_c;
RawData.MCS.MolecularData  = RawData.MCS.MolecularData  .* CF_m;

end