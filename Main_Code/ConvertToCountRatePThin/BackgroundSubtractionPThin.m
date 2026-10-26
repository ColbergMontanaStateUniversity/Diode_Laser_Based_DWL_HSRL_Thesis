function [Counts] = BackgroundSubtractionPThin(Counts,Options)
% This function subtracts the background from the lidar counts

% determine the lowest background bin index
ind = find(Counts.range >= Options.background_height,1,'first');

% determine the background
Bb = mean(Counts.Nb(ind:end,:),1,'omitnan');
Br = mean(Counts.Nr(ind:end,:),1,'omitnan');
Bc = mean(Counts.Nc(ind:end,:),1,'omitnan');
Bm = mean(Counts.Nm(ind:end,:),1,'omitnan');

% generate the background subtraction matrix using repmat
A_Bb = repmat(Bb,length(Counts.range),1);
A_Br = repmat(Br,length(Counts.range),1);
A_Bc = repmat(Bc,length(Counts.range),1);
A_Bm = repmat(Bm,length(Counts.range),1);

% subtract the background
Counts.Nb = Counts.Nb-A_Bb;
Counts.Nr = Counts.Nr-A_Br;
Counts.Nc = Counts.Nc-A_Bc;
Counts.Nm = Counts.Nm-A_Bm;

for i = 1:length(Counts.Nb_f(1,1,:))

    % determine the background
    Bb_f = mean(Counts.Nb_f(ind:end,:,i),1,'omitnan');
    Br_f = mean(Counts.Nr_f(ind:end,:,i),1,'omitnan');
    Bc_f = mean(Counts.Nc_f(ind:end,:,i),1,'omitnan');
    Bm_f = mean(Counts.Nm_f(ind:end,:,i),1,'omitnan');
    Bb_g = mean(Counts.Nb_g(ind:end,:,i),1,'omitnan');
    Br_g = mean(Counts.Nr_g(ind:end,:,i),1,'omitnan');
    Bc_g = mean(Counts.Nc_g(ind:end,:,i),1,'omitnan');
    Bm_g = mean(Counts.Nm_g(ind:end,:,i),1,'omitnan');

    % generate the background subtraction matrix using repmat
    A_Bb_f = repmat(Bb_f,length(Counts.range),1);
    A_Br_f = repmat(Br_f,length(Counts.range),1);
    A_Bc_f = repmat(Bc_f,length(Counts.range),1);
    A_Bm_f = repmat(Bm_f,length(Counts.range),1);
    A_Bb_g = repmat(Bb_g,length(Counts.range),1);
    A_Br_g = repmat(Br_g,length(Counts.range),1);
    A_Bc_g = repmat(Bc_g,length(Counts.range),1);
    A_Bm_g = repmat(Bm_g,length(Counts.range),1);

    % subtract the background
    Counts.Nb_f(:,:,i) = Counts.Nb_f(:,:,i)-A_Bb_f;
    Counts.Nb_f(isnan(Counts.Nb)) = NaN;
    Counts.Nr_f(:,:,i) = Counts.Nr_f(:,:,i)-A_Br_f;
    Counts.Nr_f(isnan(Counts.Nr)) = NaN;
    Counts.Nc_f(:,:,i) = Counts.Nc_f(:,:,i)-A_Bc_f;
    Counts.Nc_f(isnan(Counts.Nc)) = NaN;
    Counts.Nm_f(:,:,i) = Counts.Nm_f(:,:,i)-A_Bm_f;
    Counts.Nm_f(isnan(Counts.Nm)) = NaN;
    Counts.Nb_g(:,:,i) = Counts.Nb_g(:,:,i)-A_Bb_g;
    Counts.Nb_g(isnan(Counts.Nb)) = NaN;
    Counts.Nr_g(:,:,i) = Counts.Nr_g(:,:,i)-A_Br_g;
    Counts.Nr_g(isnan(Counts.Nr)) = NaN;
    Counts.Nc_g(:,:,i) = Counts.Nc_g(:,:,i)-A_Bc_g;
    Counts.Nc_g(isnan(Counts.Nc)) = NaN;
    Counts.Nm_g(:,:,i) = Counts.Nm_g(:,:,i)-A_Bm_g;
    Counts.Nm_g(isnan(Counts.Nm)) = NaN;

end

end