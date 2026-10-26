% This function will run continuously as the wind lidar collects data
% It will perform the following functions:
% Control the etalon temperature

%% 0. Pre-Code
clear all; close all;

% store the current directory 
home = pwd;

% user-defined temperature settings
disp("Setting the parameters")
T_0_desired = 21.013; %C
T_1_desired = 22.069; %C
T_bg_desired = 46.695; %C

%% 1. open the instruments

% open the pro8000
disp("Connecting to the PRO8000")
PRO8000 = visadev("GPIB0::10::INSTR");
write(PRO8000,"*IDN?");
pause(0.1)
PRO8000IDN = readline(PRO8000);
disp(PRO8000IDN)

%% 2. While loop
while_switch = 0;
error_iter = 0;
count = 0;
while while_switch == 0 && error_iter<10
    try
        %% 2.1 Lock the etalon temperature to the desired temperature
        
        % set the temperature for etalon 0 and enclosure 0
        disp("setting etalon 0 and enclosure 0 temperature")
        [T_0_etalon_act,T_0_enclosure_act] = ...
        SetEtalonTemperature(PRO8000,T_0_desired,4,5);
        
        disp(append("Etalon 0 temp = ",num2str(T_0_etalon_act)))
        disp(append("Enclosure 0 temp = ",num2str(T_0_enclosure_act)))
        
        % set the temperature for etalon 1 and enclosure 1
        disp("setting etalon 1 and enclosure 1 temperature")
        [T_1_etalon_act,T_1_enclosure_act] = ...
        SetEtalonTemperature(PRO8000,T_1_desired,7,8);
        
        disp(append("Etalon 1 temp = ",num2str(T_1_etalon_act)))
        disp(append("Enclosure 1 temp = ",num2str(T_1_enclosure_act)))
        
        % set the temperature for bg etalon
        disp("setting bg etalon temperature")
        [T_bg_etalon_act] = ...
        SetBGEtalonTemperature(PRO8000,T_bg_desired,2);
        
        disp(append("Etalon BG temp = ",num2str(T_bg_etalon_act)))
        
        pause(5)
        
        count = count + 1;
        disp(append("count = ",num2str(count)))

    catch
        error_iter = error_iter + 1;
        disp("try-catch failed")
        pause(1)
    end

end