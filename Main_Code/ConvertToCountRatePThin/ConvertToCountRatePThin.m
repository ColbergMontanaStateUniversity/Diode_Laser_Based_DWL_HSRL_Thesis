function [Counts] = ConvertToCountRatePThin(Counts,Options,RawData)
% This function converts the photon counts to photon count rates

% convert the time that each integrated bin was accumulated over
I_timeb = Options.range_step*Options.Bin_width*RawData.MCS.ProfilesPerHist(1)/2*Counts.PPHb;
I_timer = Options.range_step*Options.Bin_width*RawData.MCS.ProfilesPerHist(1)/2*Counts.PPHr;
I_timec = Options.range_step*Options.Bin_width*RawData.MCS.ProfilesPerHist(1)/2*Counts.PPHc;
I_timem = Options.range_step*Options.Bin_width*RawData.MCS.ProfilesPerHist(1)/2*Counts.PPHm;

% extend the integration time to a matrix with repmat
A_I_timeb = repmat(I_timeb,length(Counts.range),1);
A_I_timer = repmat(I_timer,length(Counts.range),1);
A_I_timec = repmat(I_timec,length(Counts.range),1);
A_I_timem = repmat(I_timem,length(Counts.range),1);
A_I_timeb_fg = repmat(I_timeb,length(Counts.range),1,Options.bootstrap_iterations);
A_I_timer_fg = repmat(I_timer,length(Counts.range),1,Options.bootstrap_iterations);
A_I_timec_fg = repmat(I_timec,length(Counts.range),1,Options.bootstrap_iterations);
A_I_timem_fg = repmat(I_timem,length(Counts.range),1,Options.bootstrap_iterations);

% convert count rate to frequency
Counts.Nb_Hz = Counts.Nb./A_I_timeb;
Counts.Nr_Hz = Counts.Nr./A_I_timer;
Counts.Nc_Hz = Counts.Nc./A_I_timec;
Counts.Nm_Hz = Counts.Nm./A_I_timem;
Counts.Nb_f_Hz = Counts.Nb_f./A_I_timeb_fg;
Counts.Nr_f_Hz = Counts.Nr_f./A_I_timer_fg;
Counts.Nc_f_Hz = Counts.Nc_f./A_I_timec_fg;
Counts.Nm_f_Hz = Counts.Nm_f./A_I_timem_fg;
Counts.Nb_g_Hz = Counts.Nb_g./A_I_timeb_fg;
Counts.Nr_g_Hz = Counts.Nr_g./A_I_timer_fg;
Counts.Nc_g_Hz = Counts.Nc_g./A_I_timec_fg;
Counts.Nm_g_Hz = Counts.Nm_g./A_I_timem_fg;

end