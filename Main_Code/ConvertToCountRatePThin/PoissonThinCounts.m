function [Counts] = PoissonThinCounts(Counts,Options)
% This function applies Poisson thinning to the integrated counts for
% Options.bootstrap_iterations iterations

% Counts  - structure containing the integrated counts Nb, Nr, Nm, Nc
% Options - structure containing bootstrap_iterations
% outputs
% Counts  - input structure with the thinned counts added:
%           Nb_f, Nb_g, Nr_f, Nr_g, Nm_f, Nm_g, Nc_f, Nc_g

% preallocate the thinned count arrays
Nb_f = zeros([size(Counts.Nb),Options.bootstrap_iterations]);
Nb_g = zeros(size(Nb_f));
Nr_f = zeros(size(Nb_f));
Nr_g = zeros(size(Nb_f));
Nm_f = zeros(size(Nb_f));
Nm_g = zeros(size(Nb_f));
Nc_f = zeros(size(Nb_f));
Nc_g = zeros(size(Nb_f));

% move the counts to local variables for parfor
Nb = Counts.Nb;
Nr = Counts.Nr;
Nm = Counts.Nm;
Nc = Counts.Nc;

% apply the Poisson thinning
parfor i = 1:Options.bootstrap_iterations
    [Nb_f_i,Nb_g_i,Nr_f_i,Nr_g_i,Nm_f_i,Nm_g_i,Nc_f_i,Nc_g_i] = ApplyPThin(Nb,Nr,Nm,Nc);
    Nb_f(:,:,i) = Nb_f_i;
    Nb_g(:,:,i) = Nb_g_i;
    Nr_f(:,:,i) = Nr_f_i;
    Nr_g(:,:,i) = Nr_g_i;
    Nm_f(:,:,i) = Nm_f_i;
    Nm_g(:,:,i) = Nm_g_i;
    Nc_f(:,:,i) = Nc_f_i;
    Nc_g(:,:,i) = Nc_g_i;
end

% store the thinned counts in the Counts structure
Counts.Nb_f = Nb_f;
Counts.Nb_g = Nb_g;
Counts.Nr_f = Nr_f;
Counts.Nr_g = Nr_g;
Counts.Nm_f = Nm_f;
Counts.Nm_g = Nm_g;
Counts.Nc_f = Nc_f;
Counts.Nc_g = Nc_g;

end