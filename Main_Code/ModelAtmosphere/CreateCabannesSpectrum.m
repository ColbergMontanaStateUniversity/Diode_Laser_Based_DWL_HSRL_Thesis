function [Atmosphere] = CreateCabannesSpectrum(Atmosphere,Path)
% This function takes the modeled atmosphere and uses it to model the
% Cabannes scattering spectrum

% store the current directory
home = pwd;

% navigate to the folder that contains the PCA for the 780-nm Cabannes
% spectrum
cd(Path.CabannesPCA)

% load the Cabannes spectrum
load(['PCA780_2465nm_7_5GHz_20.mat']);

% navigate home
cd(home)

% normalize the temperature to the standard deviation generated from the
% PCA
Tn = (double(Atmosphere.Temperature) - PCA.mu_T)/PCA.std_T;
Pn = (double(Atmosphere.Pressure)    - PCA.mu_P)/PCA.std_P;

%% use the normalized temperature and pressure values to generate a theta
% vector

% terms must be in the same order as the terms used to build the PCA in the Cabannes_PCA code 
theta = [
    Tn.^(0) .* Pn.^(0);
    Tn.^(1) .* Pn.^(0);
    Tn.^(0) .* Pn.^(1);
    Tn.^(2) .* Pn.^(0);
    Tn.^(1) .* Pn.^(1);
    Tn.^(0) .* Pn.^(2);
    Tn.^(3) .* Pn.^(0);
    Tn.^(2) .* Pn.^(1);
    Tn.^(1) .* Pn.^(2);
    Tn.^(0) .* Pn.^(3);
    Tn.^(4) .* Pn.^(0);
    Tn.^(3) .* Pn.^(1);
    Tn.^(2) .* Pn.^(2);
    Tn.^(1) .* Pn.^(3);
    Tn.^(0) .* Pn.^(4);
    Tn.^(5) .* Pn.^(0);
    Tn.^(4) .* Pn.^(1);
    Tn.^(3) .* Pn.^(2);
    Tn.^(2) .* Pn.^(3);
    Tn.^(1) .* Pn.^(4);
    Tn.^(0) .* Pn.^(5);
    Tn.^(6) .* Pn.^(0);
    Tn.^(5) .* Pn.^(1);
    Tn.^(4) .* Pn.^(2);
    Tn.^(3) .* Pn.^(3);
    Tn.^(2) .* Pn.^(4);
    Tn.^(1) .* Pn.^(5);
    Tn.^(0) .* Pn.^(6);
    Tn.^(7) .* Pn.^(0);
    Tn.^(6) .* Pn.^(1);
    Tn.^(5) .* Pn.^(2);
    Tn.^(4) .* Pn.^(3);
    Tn.^(3) .* Pn.^(4);
    Tn.^(2) .* Pn.^(5);
    Tn.^(1) .* Pn.^(6);
    Tn.^(0) .* Pn.^(7);
    Tn.^(8) .* Pn.^(0);
    Tn.^(7) .* Pn.^(1);
    Tn.^(6) .* Pn.^(2);
    Tn.^(5) .* Pn.^(3);
    Tn.^(4) .* Pn.^(4);
    Tn.^(3) .* Pn.^(5);
    Tn.^(2) .* Pn.^(6);
    Tn.^(1) .* Pn.^(7);
    Tn.^(0) .* Pn.^(8);
    Tn.^(9) .* Pn.^(0);
    Tn.^(8) .* Pn.^(1);
    Tn.^(7) .* Pn.^(2);
    Tn.^(6) .* Pn.^(3);
    Tn.^(5) .* Pn.^(4);
    Tn.^(4) .* Pn.^(5);
    Tn.^(3) .* Pn.^(6);
    Tn.^(2) .* Pn.^(7);
    Tn.^(1) .* Pn.^(8);
    Tn.^(0) .* Pn.^(9);
    Tn.^(10) .* Pn.^(0);
    Tn.^(9) .* Pn.^(1);
    Tn.^(8) .* Pn.^(2);
    Tn.^(7) .* Pn.^(3);
    Tn.^(6) .* Pn.^(4);
    Tn.^(5) .* Pn.^(5);
    Tn.^(4) .* Pn.^(6);
    Tn.^(3) .* Pn.^(7);
    Tn.^(2) .* Pn.^(8);
    Tn.^(1) .* Pn.^(9);
    Tn.^(0) .* Pn.^(10);
    Tn.^(11) .* Pn.^(0);
    Tn.^(10) .* Pn.^(1);
    Tn.^(9) .* Pn.^(2);
    Tn.^(8) .* Pn.^(3);
    Tn.^(7) .* Pn.^(4);
    Tn.^(6) .* Pn.^(5);
    Tn.^(5) .* Pn.^(6);
    Tn.^(4) .* Pn.^(7);
    Tn.^(3) .* Pn.^(8);
    Tn.^(2) .* Pn.^(9);
    Tn.^(1) .* Pn.^(10);
    Tn.^(0) .* Pn.^(11);
    Tn.^(12) .* Pn.^(0);
    Tn.^(11) .* Pn.^(1);
    Tn.^(10) .* Pn.^(2);
    Tn.^(9) .* Pn.^(3);
    Tn.^(8) .* Pn.^(4);
    Tn.^(7) .* Pn.^(5);
    Tn.^(6) .* Pn.^(6);
    Tn.^(5) .* Pn.^(7);
    Tn.^(4) .* Pn.^(8);
    Tn.^(3) .* Pn.^(9);
    Tn.^(2) .* Pn.^(10);
    Tn.^(1) .* Pn.^(11);
    Tn.^(0) .* Pn.^(12);
    Tn.^(13) .* Pn.^(0);
    Tn.^(12) .* Pn.^(1);
    Tn.^(11) .* Pn.^(2);
    Tn.^(10) .* Pn.^(3);
    Tn.^(9) .* Pn.^(4);
    Tn.^(8) .* Pn.^(5);
    Tn.^(7) .* Pn.^(6);
    Tn.^(6) .* Pn.^(7);
    Tn.^(5) .* Pn.^(8);
    Tn.^(4) .* Pn.^(9);
    Tn.^(3) .* Pn.^(10);
    Tn.^(2) .* Pn.^(11);
    Tn.^(1) .* Pn.^(12);
    Tn.^(0) .* Pn.^(13);
    Tn.^(14) .* Pn.^(0);
    Tn.^(13) .* Pn.^(1);
    Tn.^(12) .* Pn.^(2);
    Tn.^(11) .* Pn.^(3);
    Tn.^(10) .* Pn.^(4);
    Tn.^(9) .* Pn.^(5);
    Tn.^(8) .* Pn.^(6);
    Tn.^(7) .* Pn.^(7);
    Tn.^(6) .* Pn.^(8);
    Tn.^(5) .* Pn.^(9);
    Tn.^(4) .* Pn.^(10);
    Tn.^(3) .* Pn.^(11);
    Tn.^(2) .* Pn.^(12);
    Tn.^(1) .* Pn.^(13);
    Tn.^(0) .* Pn.^(14);
    Tn.^(15) .* Pn.^(0);
    Tn.^(14) .* Pn.^(1);
    Tn.^(13) .* Pn.^(2);
    Tn.^(12) .* Pn.^(3);
    Tn.^(11) .* Pn.^(4);
    Tn.^(10) .* Pn.^(5);
    Tn.^(9) .* Pn.^(6);
    Tn.^(8) .* Pn.^(7);
    Tn.^(7) .* Pn.^(8);
    Tn.^(6) .* Pn.^(9);
    Tn.^(5) .* Pn.^(10);
    Tn.^(4) .* Pn.^(11);
    Tn.^(3) .* Pn.^(12);
    Tn.^(2) .* Pn.^(13);
    Tn.^(1) .* Pn.^(14);
    Tn.^(0) .* Pn.^(15);
    Tn.^(16) .* Pn.^(0);
    Tn.^(15) .* Pn.^(1);
    Tn.^(14) .* Pn.^(2);
    Tn.^(13) .* Pn.^(3);
    Tn.^(12) .* Pn.^(4);
    Tn.^(11) .* Pn.^(5);
    Tn.^(10) .* Pn.^(6);
    Tn.^(9) .* Pn.^(7);
    Tn.^(8) .* Pn.^(8);
    Tn.^(7) .* Pn.^(9);
    Tn.^(6) .* Pn.^(10);
    Tn.^(5) .* Pn.^(11);
    Tn.^(4) .* Pn.^(12);
    Tn.^(3) .* Pn.^(13);
    Tn.^(2) .* Pn.^(14);
    Tn.^(1) .* Pn.^(15);
    Tn.^(0) .* Pn.^(16);
    Tn.^(17) .* Pn.^(0);
    Tn.^(16) .* Pn.^(1);
    Tn.^(15) .* Pn.^(2);
    Tn.^(14) .* Pn.^(3);
    Tn.^(13) .* Pn.^(4);
    Tn.^(12) .* Pn.^(5);
    Tn.^(11) .* Pn.^(6);
    Tn.^(10) .* Pn.^(7);
    Tn.^(9) .* Pn.^(8);
    Tn.^(8) .* Pn.^(9);
    Tn.^(7) .* Pn.^(10);
    Tn.^(6) .* Pn.^(11);
    Tn.^(5) .* Pn.^(12);
    Tn.^(4) .* Pn.^(13);
    Tn.^(3) .* Pn.^(14);
    Tn.^(2) .* Pn.^(15);
    Tn.^(1) .* Pn.^(16);
    Tn.^(0) .* Pn.^(17);
    Tn.^(18) .* Pn.^(0);
    Tn.^(17) .* Pn.^(1);
    Tn.^(16) .* Pn.^(2);
    Tn.^(15) .* Pn.^(3);
    Tn.^(14) .* Pn.^(4);
    Tn.^(13) .* Pn.^(5);
    Tn.^(12) .* Pn.^(6);
    Tn.^(11) .* Pn.^(7);
    Tn.^(10) .* Pn.^(8);
    Tn.^(9) .* Pn.^(9);
    Tn.^(8) .* Pn.^(10);
    Tn.^(7) .* Pn.^(11);
    Tn.^(6) .* Pn.^(12);
    Tn.^(5) .* Pn.^(13);
    Tn.^(4) .* Pn.^(14);
    Tn.^(3) .* Pn.^(15);
    Tn.^(2) .* Pn.^(16);
    Tn.^(1) .* Pn.^(17);
    Tn.^(0) .* Pn.^(18);
    Tn.^(19) .* Pn.^(0);
    Tn.^(18) .* Pn.^(1);
    Tn.^(17) .* Pn.^(2);
    Tn.^(16) .* Pn.^(3);
    Tn.^(15) .* Pn.^(4);
    Tn.^(14) .* Pn.^(5);
    Tn.^(13) .* Pn.^(6);
    Tn.^(12) .* Pn.^(7);
    Tn.^(11) .* Pn.^(8);
    Tn.^(10) .* Pn.^(9);
    Tn.^(9) .* Pn.^(10);
    Tn.^(8) .* Pn.^(11);
    Tn.^(7) .* Pn.^(12);
    Tn.^(6) .* Pn.^(13);
    Tn.^(5) .* Pn.^(14);
    Tn.^(4) .* Pn.^(15);
    Tn.^(3) .* Pn.^(16);
    Tn.^(2) .* Pn.^(17);
    Tn.^(1) .* Pn.^(18);
    Tn.^(0) .* Pn.^(19);
];

% Compute dimensions
[m_flat, n] = size(theta);            % m_flat = number of range bins x number of polynomial terms, n = number of time bins
m = size(Atmosphere.Temperature, 1);  % m = number of range bins
p = m_flat / m;                       % p = number of polynomial terms (210 for a maximum degree of 19)
if mod(m_flat, m) ~= 0
    error('theta has inconsistent dimensions');
end

% Reshape theta for matrix multiplication
theta = reshape(theta, m, p, n);         % [range × term × time]
theta = permute(theta, [1 3 2]);         % [range × time × term]
theta_reshaped = reshape(theta, [], p);  % [range*time × term]

% Compute Y using matrix multiplication and reshaping
Y_reshaped = PCA.mu_Y + PCA.M * theta_reshaped.';

% Reshape Y back to the desired dimensions 
Y = reshape(Y_reshaped.', [m, n, length(PCA.mu_Y)]);

% clear large variables from memory
clear theta Tn Pn theta_reshaped Y_reshaped m n p

% store the frequency shift vector and the Cabannes spectra in Atmosphere

Atmosphere.nu_shift = PCA.nu_shift;
Atmosphere.Cabannes = Y;


end