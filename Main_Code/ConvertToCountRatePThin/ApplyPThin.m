function [Nb_f,Nb_g,Nr_f,Nr_g,Nm_f,Nm_g,Nc_f,Nc_g] = ApplyPThin(Nb,Nr,Nm,Nc)

% This function applies Poisson thinning to the integrated counts of each
% channel by calling PoissThin.py, which must be in the same folder. Each
% count array is split into two thinned arrays, f and g. Cells that are NaN
% or negative in the input are set to NaN in both outputs.
% inputs
% Nb, Nr, Nm, Nc - integrated counts for the blue, red, molecular, and
%                  combined channels (range x time)
% outputs
% Nb_f, Nb_g, ... - the two thinned count arrays for each channel

% HARD-CODED: path to the Python environment containing numpy; change to
% your own environment. Python is restarted on each call.

terminate(pyenv);
pyenv('Version', 'C:\Users\lukec\miniconda3\envs\Pthin\python.exe', 'ExecutionMode', 'OutOfProcess');

I = isnan(Nb) | Nb < 0;
Nb = int64(round(Nb));
Nb(I) = 0;

result = py.PoissThin.PoissThin(py.numpy.array(Nb));
F = double(result{1});
G = double(result{2});
F(I) = NaN; G(I) = NaN;
Nb_f = F;
Nb_g = G;

I = isnan(Nr) | Nr < 0;
Nr = int64(round(Nr));
Nr(I) = 0;

result = py.PoissThin.PoissThin(py.numpy.array(Nr));
F = double(result{1});
G = double(result{2});
F(I) = NaN; G(I) = NaN;
Nr_f = F;
Nr_g = G;

I = isnan(Nm) | Nm < 0;
Nm = int64(round(Nm));
Nm(I) = 0;

result = py.PoissThin.PoissThin(py.numpy.array(Nm));
F = double(result{1});
G = double(result{2});
F(I) = NaN; G(I) = NaN;
Nm_f = F;
Nm_g = G;

I = isnan(Nc) | Nc < 0;
Nc = int64(round(Nc));
Nc(I) = 0;

result = py.PoissThin.PoissThin(py.numpy.array(Nc));
F = double(result{1});
G = double(result{2});
F(I) = NaN; G(I) = NaN;
Nc_f = F;
Nc_g = G;

end