function [Tetalon_act] = ...
    SetBGEtalonTemperature(Instrument,Tetalon_desired,Etalon_slot)
% This function maintains the etalon and the enclosure at the set
% temperature

%% Etalon
% Read etalon temperature
[Tetalon_act] = ReadPRO8000Temperature(Instrument,Etalon_slot,30); % 30 is hardcoded number of readings averaged
[Tetalon_set] = ReadPRO8000SetTemperature(Instrument,Etalon_slot);

% find the temperature difference
diff = Tetalon_act - Tetalon_desired;

% If T_difference > 1 mK, set etalon temperature
if abs(diff) > .001
    SetPRO8000TemperatureBG(Instrument,Etalon_slot,Tetalon_set-(diff*0.6)) % feedback gain of 0.6. Keep between 0.5 and 1
end


end