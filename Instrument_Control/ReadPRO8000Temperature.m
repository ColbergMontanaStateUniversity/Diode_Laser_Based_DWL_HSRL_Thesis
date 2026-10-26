function [Temperature] = ReadPRO8000Temperature(Instrument,Slot,Number_Samples)
% this function reads the temperature of the Thorlabs controller for a
% specified slot

write(Instrument,append(":SLOT ",num2str(Slot)));
pause(0.001)
T_temp = zeros(1,Number_Samples);
for i = 1:length(T_temp)
    try
        pause(0.001)
        write(Instrument,":TEMP:ACT?");
        pause(0.001)
        ch = char(readline(Instrument));
        ind_ch_1 = find(ch == ' ');
        ind_ch_2 = find(ch == '+');
        T_temp(i) = str2double(ch(ind_ch_1:ind_ch_2+2));
    catch
        T_temp(i) = NaN;
    end
end 

Temperature = mean(T_temp,'omitnan');

end