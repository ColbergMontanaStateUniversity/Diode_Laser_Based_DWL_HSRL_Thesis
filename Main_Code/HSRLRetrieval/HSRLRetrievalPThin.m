function [HSRL] = HSRLRetrievalPThin(Counts,Atmosphere,HSRLCal,Options)
% This function performs the HSRL retrieval

%% Pre-code

Tc = HSRLCal.Temperature;
Pc = HSRLCal.Pressure;

% Convert pressure and temperature from structure fields to variables
P = double(Atmosphere.Pressure);
T = double(Atmosphere.Temperature);

% Convert the count rates and their uncertainties from structure fields to
% variables
Nm = Counts.Nm_Hz;
Nc = Counts.Nc_Hz;
Nm_f = Counts.Nm_f_Hz;
Nc_f = Counts.Nc_f_Hz;
Nm_g = Counts.Nm_g_Hz;
Nc_g = Counts.Nc_g_Hz;

%% Determine the calibration constants through interpolation
F_Cmm = griddedInterpolant({Tc, Pc}, HSRLCal.Cmm, 'linear', 'none');
Cmm = F_Cmm(T, P);

F_Cmc = griddedInterpolant({Tc, Pc}, HSRLCal.Cmc, 'linear', 'none');
Cmc = F_Cmc(T, P);

F_Cam = griddedInterpolant({Tc, Pc}, HSRLCal.Cam, 'linear', 'none');
Cam = F_Cam(T, P);


%% Backscatter Ratio
BR = 1 - (Cmm.*Nc - Cmc.*Nm)./(Cam.*Nc - Nm);

BR_f = zeros(size(Counts.Nb_f));
BR_g = zeros(size(Counts.Nb_f));

for i = 1:Options.bootstrap_iterations
    BR_f(:,:,i) = 1 - (Cmm.*Nc_f(:,:,i) - Cmc.*Nm_f(:,:,i))./(Cam.*Nc_f(:,:,i) - Nm_f(:,:,i));
    BR_g(:,:,i) = 1 - (Cmm.*Nc_g(:,:,i) - Cmc.*Nm_g(:,:,i))./(Cam.*Nc_g(:,:,i) - Nm_g(:,:,i));
end


%% Molecular backscatter coefficient model
% model the molecular backscatter coefficient based on the modeled
% temperature and pressure
Beta_mol = 9.4284e-8*(P)   ./(T)   ;

%% Aerosol backscatter coefficient
% the aerosol backscatter coefficient and its uncertainty determined from
% the measured backscatter ratio and the modeled molecular backscatter
% coefficient 

Beta_aer = (BR-1).*Beta_mol;

Beta_aer_f = zeros(size(Counts.Nb_f));
Beta_aer_g = zeros(size(Counts.Nb_f));
for i = 1:Options.bootstrap_iterations
    Beta_aer_f(:,:,i) = (BR_f(:,:,i)-1).*Beta_mol;
    Beta_aer_g(:,:,i) = (BR_g(:,:,i)-1).*Beta_mol;
end

% store the variables in the HSRL structure
HSRL.r              = Counts.range;
HSRL.t              = Counts.time;
HSRL.BR             = BR;
HSRL.BR_f           = BR_f;
HSRL.BR_g           = BR_g;
HSRL.Beta_mol       = Beta_mol;
HSRL.Beta_aer       = Beta_aer;
HSRL.Beta_aer_f     = Beta_aer_f;
HSRL.Beta_aer_g     = Beta_aer_g;

end