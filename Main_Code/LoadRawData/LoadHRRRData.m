function [HRRRData] = LoadHRRRData(day,month,year,Path)
    % This function loads the HRRR data

% outputs
% HRRRData - structure containing the following fields, where each column
% of the pressure-level fields corresponds to one entry of HRRRData.time
% HRRRData.time                      - hours since 0:00 UTC, read from the filename
% HRRRData.pressure_levels           - pressure of each level (hPa), 39 x N
% HRRRData.geopotential_height       - geopotential height of each pressure level (m), 39 x N
% HRRRData.temperature               - temperature at each pressure level (K), 39 x N
% HRRRData.relative_humidity         - relative humidity at each pressure level (%), 39 x N
% HRRRData.PBLH                      - planetary boundary layer height (m), N x 1
% HRRRData.temperature_2meter        - 2 m temperature (K), N x 1
% HRRRData.relative_humidity_2_meter - 2 m relative humidity (%), N x 1
% HRRRData.surface_pressure          - surface pressure (hPa), N x 1

    % store the home directory 
    home = pwd;

    % turn the day, month, and year variables into a string to open the
    % folder containing the raw data
    foldername = string(year);

    if month >= 10
        foldername = strcat(foldername,num2str(month));
    else
        foldername = strcat(foldername,"0",num2str(month));
    end

    if day >= 10
        foldername = strcat(foldername,num2str(day));
    else
        foldername = strcat(foldername,"0",num2str(day));
    end

    cd(Path.HRRRData)
    cd(foldername)

    Directory = dir("hrrr*.nc");
    

    time = [];


    for i = 1:length(Directory)

        time_char = char(Directory(i).name);
        time =[time;str2double(time_char(20:21))];

    end

    pressure_levels = zeros(39,numel(time));
    geopotential_height = zeros(39,numel(time));
    temperature = zeros(39,numel(time));
    relative_humidity = zeros(39,numel(time));
    PBLH = zeros(size(time));
    temperature_2meter = zeros(size(time));
    relative_humidity_2_meter = zeros(size(time));
    surface_pressure = zeros(size(time));

    for i = 1:length(Directory)

        pressure_levels_temp = ncread(Directory(i).name,"pres_levels");
        pressure_levels(:,i) = pressure_levels_temp;

        geopotential_height_temp = ncread(Directory(i).name,"Geopotential_Height_PresLevel_HRRR");
        geopotential_height(:,i) = geopotential_height_temp;

        temperature_temp = ncread(Directory(i).name,"Temperature_PresLevel_HRRR");
        temperature(:,i) = temperature_temp;

        relative_humidity_temp = ncread(Directory(i).name,"Relative_Humidity_PresLevel_HRRR");
        relative_humidity(:,i) = relative_humidity_temp;

        PBLH_temp = ncread(Directory(i).name,"HPBL_HRRR");
        PBLH(i) = PBLH_temp;

        temperature_2meter_temp = ncread(Directory(i).name,"T_2_meter_HRRR");
        temperature_2meter(i) = temperature_2meter_temp;

        relative_humidity_2_meter_temp = ncread(Directory(i).name,"RH_2_meter_HRRR");
        relative_humidity_2_meter(i) = relative_humidity_2_meter_temp;

        surface_pressure_temp = ncread(Directory(i).name,"Pressure_surface_HRRR");
        surface_pressure(i) = surface_pressure_temp;
    end

    HRRRData.time = time;
    HRRRData.pressure_levels = pressure_levels;
    HRRRData.geopotential_height = geopotential_height;
    HRRRData.temperature = temperature;
    HRRRData.relative_humidity = relative_humidity;
    HRRRData.PBLH = PBLH;
    HRRRData.temperature_2meter = temperature_2meter;
    HRRRData.relative_humidity_2_meter = relative_humidity_2_meter;
    HRRRData.surface_pressure = surface_pressure/100; % convert from Pa to hPa

    cd(home)

end