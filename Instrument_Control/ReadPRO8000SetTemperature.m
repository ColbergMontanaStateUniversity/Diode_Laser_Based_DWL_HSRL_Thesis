function [Temperature] = ReadPRO8000SetTemperature(Instrument,Slot)
% this function reads the temperature of the Thorlabs controler for a
% specified flot

write(Instrument,append(":SLOT ",num2str(Slot)));
pause(0.001)

try
    pause(0.001)
    write(Instrument,":TEMP:SET?");
    pause(0.001)
    ch = char(readline(Instrument));
    ind_ch_1 = find(ch == ' ');
    ind_ch_2 = find(ch == '+');
    T_temp = str2double(ch(ind_ch_1:ind_ch_2+2));
catch
    T_temp = NaN;
end

Temperature = mean(T_temp,'omitnan');

end