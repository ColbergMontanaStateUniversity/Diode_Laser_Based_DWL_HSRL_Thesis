function [Atmosphere] = CreateAtmosphere(HRRRData,Constants,Counts)
% This function creates the modeled temperature and pressure fields on the
% lidar range and time grid from the HRRR model data
% inputs
% HRRRData  - structure containing the HRRR model data from LoadHRRRData
% Constants - structure containing the constants (uses Constants.elevation,
%             the elevation of the lidar site above sea level in m)
% Counts    - structure containing the lidar time (hours since 0:00 UTC)
%             and range (m) vectors
% outputs
% Atmosphere - a structure containing the following fields
% Atmosphere.Temperature         - atmospheric temperature (K), range x time
% Atmosphere.Pressure            - atmospheric pressure (hPa), range x time
% Atmosphere.Surface_Temperature - 2 m temperature at the site (K), 1 x time
% Atmosphere.Surface_Pressure    - surface pressure at the site (hPa), 1 x time
% Atmosphere.time                - time vector (hours since 0:00 UTC), same as Counts.time

% convert the geopotential height from the HRRR model to altitude
el_0 = Constants.elevation;

tH  = HRRRData.time;
TH_S = HRRRData.temperature_2meter;
PH_S = HRRRData.surface_pressure;

EH_old = HRRRData.geopotential_height - el_0;
EH = repmat(mean(EH_old,2),[1 length(tH)]);
TH_old = HRRRData.temperature;
PH_old = HRRRData.pressure_levels;

ind_del = mean(EH,2)<100; % drops data below the surface
EH(ind_del,:) = [];

EH = [zeros(1,length(HRRRData.time));EH];
TH = zeros(size(EH));
PH = zeros(size(EH));

for i = 1:length(tH)

    TH(:,i) = interp1(EH_old(:,i),TH_old(:,i),EH(:,i),'linear','extrap');
    PH(:,i) = interp1(EH_old(:,i),PH_old(:,i),EH(:,i),'linear','extrap');

end

TH(1,:) = TH_S';
PH(1,:) = PH_S';

% interpolate the HRRR temperature and pressure to the lidar range and time
% grid. This assumes the lidar points vertically, so range = height above
% the site. For an off-zenith pointing angle, use range*sin(elevation angle).
[XQ,YQ] = meshgrid(double(Counts.time),double(Counts.range));

Atmosphere.Temperature = interp2(repmat(tH',[length(EH(:,1)) 1]),EH,TH,XQ,YQ,'linear');  
Atmosphere.Pressure    = interp2(repmat(tH',[length(EH(:,1)) 1]),EH,PH,XQ,YQ,'linear');

Atmosphere.Temperature = fillmissing(Atmosphere.Temperature,'nearest',2);
Atmosphere.Pressure    = fillmissing(Atmosphere.Pressure   ,'nearest',2);

% create the surface temperature and pressure vectors
t = Counts.time;
Atmosphere.Surface_Temperature = interp1(tH,TH_S,t,'linear','extrap');
Atmosphere.Surface_Pressure    = interp1(tH,PH_S,t,'linear','extrap');

% store the time vector
Atmosphere.time = Counts.time;

end