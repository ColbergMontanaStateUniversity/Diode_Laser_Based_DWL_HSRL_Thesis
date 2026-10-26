function [Winds] = WindUncertaintyPThin(Winds,Options)

% This function estimates the uncertainty of the radial wind velocity and
% the Doppler shift from the Poisson-thinned arrays. The variance of each
% is 1/(2(N-1))*sum((X_f - X_g)^2), where X is Vr or Df and N is the
% number of bootstrap iterations. Vr_std is equal to Df_std/2.563293e6.

Vr_diff_squared = (Winds.Vr_f - Winds.Vr_g).^2;
sum_Vr_diff_squared = sum(Vr_diff_squared,3);
Vr_var = 1/(2*(Options.bootstrap_iterations-1))*sum_Vr_diff_squared;
Winds.Vr_std = Vr_var.^0.5;

Df_diff_squared = (Winds.Df_f - Winds.Df_g).^2;
sum_Df_diff_squared = sum(Df_diff_squared,3);
Df_var = 1/(2*(Options.bootstrap_iterations-1))*sum_Df_diff_squared;
Winds.Df_std = Df_var.^0.5;

end