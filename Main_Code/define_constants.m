function [Constants] = define_constants()
%This function serves to contain all  of the constant parameters.
    %define constant parameters
        Constants.g     =         9.8021; % [m/s^2] the gravitational acceleration at Bozeman, Montana
        Constants.M_air =      0.0289644; % [kg/mol] the molar mass of air 
        Constants.R     =      8.3144598; % [J/(mol*K)] the universal gas constant
        Constants.c     =      299792458; % [m/s] the speed of light
        Constants.kb    = 1.38064852e-23; % [J/K] or [m^2*kg/(s^2*K)] Boltzmann's Constant
        Constants.h     = 6.62070015e-34; % [J*s] or [m^2*kg/s] Planck's Constant
        Constants.m_H2O =     2.9915e-26; % [kg] the mass of a molecule of water
        Constants.m_air =     4.8097E-26; % [kg] the mass of a molecule of dry air    
        Constants.elevation =       1524; % [m] above-sea-level elevation of Cobleigh Hall
        Constants.lambda_0 = 780.24635e-9; % [m] wavelength of the transmitted laser
end