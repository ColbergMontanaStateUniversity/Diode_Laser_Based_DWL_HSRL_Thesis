function [Winds] = ConvertDopplerShiftToWindSpeed(Winds)

% This function converts the Doppler shifts (Hz) to radial wind velocities
% (m/s) using Vr = -Df*lambda/2. The factor 2.563293e6 = 2/lambda is for
% 780.24635 nm and must change with the laser wavelength. A negative
% Doppler shift gives a positive radial velocity.

Winds.Vr = Winds.Df./-2.563293e6; % for 780.24635 nm

Winds.Vr_f = Winds.Df_f./-2.563293e6;
Winds.Vr_g = Winds.Df_g./-2.563293e6;

end