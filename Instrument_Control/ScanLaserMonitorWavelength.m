clear all; close all;

% open the LDC-3724c
disp("Connecting to the ILX controller")
ILX = visadev("GPIB0::1::INSTR"); % ILX controller address
write(ILX,"*IDN?");
ILXIDN = readline(ILX);
pause(0.1)
disp('Connection established to ILX Controller.');

% open the wavemeter
ipAddress = '192.168.0.166'; % wavemeter address
port = 23;
WavemeterClient = tcpclient(ipAddress, port);
disp('Connection established to wavemeter.');

% set the laser temperature to 18.6
T = 18.6; % laser temperature setpoint
SETILXTemp(ILX,T)
pause(0.1)

I = [129.00:.1:159.00,159.00:-.1:129.00]; % current scan vector in mA

filename = '20260914_1_46695_21013_22069_60_Cal_Scan_ILX_Wave';

ILX_Wave_Data.Tact      = [];
ILX_Wave_Data.Tact_dt   = [];
ILX_Wave_Data.Iact      = [];
ILX_Wave_Data.Iact_dt   = [];
ILX_Wave_Data.Lambda    = [];
ILX_Wave_Data.Lambda_dt = [];
ILX_Wave_Data.Start_dt  = [];
ILX_Wave_Data.End_dt  = [];
ILX_Wave_Data.Power     = [];
ILX_Wave_Data.Power_dt  = [];

count = 0;
for i = 1:length(I)
        
    % Set the laser current to the ith position in the current vector
    disp(append("i = ",num2str(i)))
    SETILXCurrent(ILX,I(i))
    pause(0.1)

    % pause and let the instrument settle
    pause(5)
    ILX_Wave_Data.Start_dt = [ILX_Wave_Data.Start_dt;datestr(datetime('now'), 'dd-mmm-yyyy HH:MM:SS')];

    % What is the actual temperature and current?
    T_act =  ReadILXTemperature(ILX);
    ILX_Wave_Data.Tact = [ILX_Wave_Data.Tact,T_act];
    ILX_Wave_Data.Tact_dt = [ILX_Wave_Data.Tact_dt;datestr(datetime('now'), 'dd-mmm-yyyy HH:MM:SS')];

    pause(0.001)
    I_act =  ReadILXCurrent(ILX);
    ILX_Wave_Data.Iact = [ILX_Wave_Data.Iact,I_act];
    ILX_Wave_Data.Iact_dt = [ILX_Wave_Data.Iact_dt;datestr(datetime('now'), 'dd-mmm-yyyy HH:MM:SS')];

    % What is the wavelength
    for j = 1:5
        pause(0.1)
        try
            [Lambda,Power] = ReadBristolWavemeter(WavemeterClient);
        catch
            % keep 5 readings per step so the calibration reshape still works
            Lambda = NaN;
            Power  = NaN;
            disp("Wavemeter read failed")
        end
        ILX_Wave_Data.Lambda = [ILX_Wave_Data.Lambda;Lambda];
        ILX_Wave_Data.Power  = [ILX_Wave_Data.Power ;Power];
        ILX_Wave_Data.Lambda_dt = [ILX_Wave_Data.Lambda_dt;datestr(datetime('now'), 'dd-mmm-yyyy HH:MM:SS')];
        ILX_Wave_Data.Power_dt  = [ILX_Wave_Data.Power_dt ;datestr(datetime('now'), 'dd-mmm-yyyy HH:MM:SS')];
    end
    count = count+1;

    pause(5)
    ILX_Wave_Data.End_dt = [ILX_Wave_Data.End_dt;datestr(datetime('now'), 'dd-mmm-yyyy HH:MM:SS')];
    pause(2)

    % Save the data every 25 iterations
    if rem(count,25) == 0
        disp("Saving data")
        save(append(filename,".mat"),'ILX_Wave_Data');
    end

end

disp("Saving data")
save(append(filename,".mat"),'ILX_Wave_Data');