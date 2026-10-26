clear all; close all;

% open the wavemeter
ipAddress = '192.168.0.166'; % wavemeter ip address
port = 23; % wavemeter port
WavemeterClient = tcpclient(ipAddress, port);
disp('Connection established to wavemeter.');

filename = '20261015_1_Locked_Wave'; % change to desired filename

Wave.Lambda    = [];
Wave.Lambda_dt = [];
Wave.Power     = [];
Wave.Power_dt  = [];

error_iter = 0;
count = 0;
while error_iter<10

    error_iter = 0;

    try

        count = count + 1;
        disp(append("count = ",num2str(count)))

        pause(1)
        [Lambda,Power] = ReadBristolWavemeter(WavemeterClient);
        Wave.Lambda = [Wave.Lambda;Lambda];
        Wave.Power  = [Wave.Power ;Power];
        Wave.Lambda_dt = [Wave.Lambda_dt;datestr(datetime('now'), 'dd-mmm-yyyy HH:MM:SS')];
        Wave.Power_dt  = [Wave.Power_dt ;datestr(datetime('now'), 'dd-mmm-yyyy HH:MM:SS')];
   
        if rem(count,100) == 0
            disp("Saving data")
            save(append(filename,".mat"), 'Wave');
        end

    catch
        error_iter = error_iter + 1;
        disp("try-catch failed")
    end

end

save(append(filename,".mat"), 'Wave');