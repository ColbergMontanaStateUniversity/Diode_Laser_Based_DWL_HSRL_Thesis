function [Counts] = FindDDSignalPThin(Counts)
% This function find the direct-detection signal M

% Equation 8 in Repasky et al. (2022) JTECH paper
Counts.M = ((Counts.Nr_Hz - Counts.Nb_Hz)./(Counts.Nr_Hz + Counts.Nb_Hz));
Counts.M_f = ((Counts.Nr_f_Hz - Counts.Nb_f_Hz)./(Counts.Nr_f_Hz + Counts.Nb_f_Hz));
Counts.M_g = ((Counts.Nr_g_Hz - Counts.Nb_g_Hz)./(Counts.Nr_g_Hz + Counts.Nb_g_Hz));

end