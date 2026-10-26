function [Tetalon_act,Tenclosure_act] = ...
    SetEtalonTemperature(Instrument,Tetalon_desired,Etalon_slot,Enclosure_slot)

% This function maintains the etalon and the enclosure at the set
% temperature

%% Etalon
% Read etalon temperature
[Tetalon_act] = ReadPRO8000Temperature(Instrument,Etalon_slot,30); % 30 is hard-coded number of readings averaged
[Tetalon_set] = ReadPRO8000SetTemperature(Instrument,Etalon_slot);

% find the temperature difference
diff = Tetalon_act - Tetalon_desired;

% If T_difference > .5 mK, set etalon temperature
if abs(diff) > .0005
    SetPRO8000Temperature(Instrument,Etalon_slot,Tetalon_set-(diff*0.667)) % 0.667 is feedback gain. Keep between 0.5 and 1.
end

%% Enclosure
% Read enclosure temperature
[Tenclosure_act] = ReadPRO8000Temperature(Instrument,Enclosure_slot,30);

[Tenclosure_set] = ReadPRO8000SetTemperature(Instrument,Enclosure_slot);

% find the temperature difference
diff = Tenclosure_act - Tetalon_desired;

% If T_difference > 1 mK, set enclosure temperature
if abs(diff) > .001
    SetPRO8000Temperature(Instrument,Enclosure_slot,Tenclosure_set-(diff*0.667))
end

end