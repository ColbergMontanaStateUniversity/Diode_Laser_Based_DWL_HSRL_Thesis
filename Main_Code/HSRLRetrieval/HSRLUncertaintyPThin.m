function [HSRL] = HSRLUncertaintyPThin(HSRL,Options)
% This function estimates the uncertainty of the backscatter ratio (B) and
% the aerosol backscatter coefficient from the Poisson-thinned arrays.
% The variance of each is 1/(2(N-1))*sum((X_f - X_g)^2), where X is B or
% Beta_aer and N is the number of bootstrap iterations. Because
% Beta_aer_f - Beta_aer_g = (B_f - B_g)*Beta_mol, the aerosol backscatter
% uncertainty is equal to BR_std.*Beta_mol.

% the variance of the Poisson-thinned B is 1/(2(N-1))*sum((B_g-B_f)^2),
% where N is the number of bootstrap iterations

BR_diff_squared = (HSRL.BR_f - HSRL.BR_g).^2;
sum_BR_diff_squared = sum(BR_diff_squared,3);
BR_var = 1/(2*(Options.bootstrap_iterations-1))*sum_BR_diff_squared;
HSRL.BR_std = BR_var.^0.5;

Beta_aer_diff_squared = (HSRL.Beta_aer_f - HSRL.Beta_aer_g).^2;
sum_Beta_aer_diff_squared = sum(Beta_aer_diff_squared,3);
Beta_aer_var = 1/(2*(Options.bootstrap_iterations-1))*sum_Beta_aer_diff_squared;
HSRL.Beta_aer_std = Beta_aer_var.^0.5;

end