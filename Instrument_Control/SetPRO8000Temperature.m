function [] = SetPRO8000Temperature(Instrument,Slot,Set_Temperature)

% This function sets the temperature of the PRO8000

if isnan(Set_Temperature)
   error("Set temperature is NaN")
end

if Set_Temperature>30
    error("Set temperature is too hot")
end

if Set_Temperature<10
    error("Set temperature is too cold")
end

% switch to the correct slot
write(Instrument,append(":SLOT ",num2str(Slot)));
pause(0.001)
%set the temperature
str = num2str(Set_Temperature);
write(Instrument,append(":TEMP:SET ",str));
pause(0.001)

end