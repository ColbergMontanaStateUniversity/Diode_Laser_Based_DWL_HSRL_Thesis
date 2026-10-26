function [Receiver] = LoadReceiver(Path,Options)
% This function loads in the transmission curves from the receiver scans

home = pwd;

% navigate to the folder that contains the receiver curves
cd(Path.CalibrationData)

% load the calibration curves
load(Options.ReceiverScans_filename)

% convert the variables to structure fields
Receiver.nu_shift = freqhz;
Receiver.Tb = [Tblue(1:end)];
Receiver.Tr = [Tred(1:end)];

% fixes NaNs by holding them constant at the edge of the range. Does not
% affect wind speed retrievals
Receiver.Tb = fillmissing(Receiver.Tb,'nearest');
Receiver.Tr = fillmissing(Receiver.Tr,'nearest');


% navigate back to the home directory
cd(home)

end