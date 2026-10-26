function [Winds] = FindDopplerShiftPThin(Winds,Counts,HSRL,Receiver,Atmosphere,Options)
% This function finds the radial wind speed from the measured
% direct-detection signal, the measured backscatter ratio, the measured
% receiver transmission curves, and the modeled atmospheric Cabannes
% spectra

% this function limits the search from -1 GHz to +1 GHz (-390 m/s to +390
% m/s)
% Equation 8 in Repasky et al. (2022) JTECH Paper
% M(r) = (A1 + B1)/(A2 +B2)
% Where A1 = (B(r)-1)*(eta_a*T_e,a(f = f0 + Df)-eta_b*T_e,b(f = f0 + Df))
%       B1 = int[g(r,f0 + Df,f)*(eta_a*T_a-eta_b*T_b)df]
%       A2 = (B(r)-1)*(eta_a*T_e,a(f = f0 + Df)+eta_b*T_e,b(f = f0 + Df))
%       B2 = int[g(r,f0 + Df,f)*(eta_a*T_a+eta_b*T_b)df]

% Df is a vector of guesses, position represented by h
% i represents the ith range bin
% j represents the jth time bin

% (B(r)-1) = HSRL.BR - 1
% eta_a*T_e,a(f = f0 + Df(h)) = interp1(Receiver.nu_shift,Receiver.Tr,Df(h))
% eta_b*T_e,b(f = f0 + Df(h)) = interp1(Receiver.nu_shift,Receiver.Tb,Df(h))
% g(r,f0 + Df,f) = interp1(Atmosphere.nu_shift+Df,Atmosphere.Cabannes(i,j,:),Atmosphere.nu_shift,'linear','extrap')
% int[g(r,f0 + Df,f)*(eta_a*T_a-eta_b*T_b)df] = trapz(Atmosphere.nu_shift,g(r,f0 + Df,f){from above}.*(Receiver.Tr - Receiver.Tb))

%Preallocate f and g Doppler shift arrays
Winds.Df_f = zeros(size(Counts.Nb_f));
Winds.Df_g = zeros(size(Counts.Nb_f));

% Cache difference and sum of receiver channel
Receiver_diff = Receiver.Tr - Receiver.Tb;
Receiver_sum = Receiver.Tr + Receiver.Tb;

%Caching variables so that structures don't need to be accessed by parfor
%workers
Li = size(Counts.M, 1);
Lj = size(Counts.M, 2);
logic = (isnan(Counts.M) | isnan(HSRL.BR(1:Li,1:Lj)));
A_nu_shift = Atmosphere.nu_shift;
A_Cabannes = Atmosphere.Cabannes;
R_Tr = Receiver.Tr;
R_Tb = Receiver.Tb;
R_nu_shift = Receiver.nu_shift;

% Interpolate each vector to match A_nu_shift
R_Tb         = interp1(R_nu_shift, R_Tb, A_nu_shift, 'linear', 'extrap');
R_Tr         = interp1(R_nu_shift, R_Tr, A_nu_shift, 'linear', 'extrap');
Receiver_diff = interp1(R_nu_shift, Receiver_diff, A_nu_shift, 'linear', 'extrap');
Receiver_sum  = interp1(R_nu_shift, Receiver_sum,  A_nu_shift, 'linear', 'extrap');
R_nu_shift = A_nu_shift;

ind_del = (A_nu_shift<-4e9 | A_nu_shift>4e9);
A_nu_shift(ind_del) = [];
A_Cabannes(:,:,ind_del) = [];

ind_del = (R_nu_shift<-4e9 | R_nu_shift>4e9);
R_Tr(ind_del) = [];
R_Tb(ind_del) = [];
Receiver_diff(ind_del) = [];
Receiver_sum(ind_del) = [];
R_nu_shift(ind_del) = [];

clear ind_del
tic
for k = 1:Options.bootstrap_iterations
    C_M = Counts.M_f(:,:,k);
    BR = HSRL.BR_f(:,:,k);
    
    %preallocate the solution
    sol = NaN(size(C_M));
    parfor i = 1:Li
        % inner_tic = tic;
        local_sol = NaN(1,Lj);
        for j = 1:Lj
            if logic(i,j) == 1
                local_sol(j) = NaN;
            else
                error = 1;
                iter = 1;
                Df = [-1e9 0 1e9];
                %Cache interpolations
                Tr_interp = interp1(R_nu_shift,R_Tr,Df);
                Tb_interp = interp1(R_nu_shift,R_Tb,Df);
    
                M = NaN(1,length(Df));
                while error>1e-6
                    for h = 1:length(Df)
                        if isnan(M(h))
                            nu_shift_Df_h = A_nu_shift + Df(h);
                            Cabannes_interp = interp1(nu_shift_Df_h, squeeze(A_Cabannes(i,j,:)), A_nu_shift, 'linear', 'extrap');
                            
                            %% A1 and A2
                            A1 = (BR(i,j) - 1)*(Tr_interp(h)-Tb_interp(h));
                            A2 = (BR(i,j) - 1)*(Tr_interp(h)+Tb_interp(h));
                            
                            %% B1 and B2
                            B1 = trapz(A_nu_shift,Cabannes_interp.*Receiver_diff);
                            B2 = trapz(A_nu_shift,Cabannes_interp.*Receiver_sum);
                            
                            M(h) = (A1+B1)/(A2+B2);
                        end
                    end
                    diff = abs(C_M(i,j) - M);
                    [error,I] = min(diff);
                    iter = iter +1;
        
                    if error > 1e-6 
                        % Select new interval based on the error
                        if I == 1
                            Df = linspace(Df(1), Df(2), 3);
                            M = [M(1) NaN M(2)];
                        elseif I == length(Df)
                            Df = linspace(Df(end-1), Df(end), 3);
                            M = [M(end-1) NaN M(end)];
                        else
                            if C_M(i,j) > M(2)
                                Df = linspace(Df(I-1), Df(I), 3);
                                M = [M(I-1) NaN M(I)];
                            else
                                Df = linspace(Df(I), Df(I+1), 3);
                                M = [M(I) NaN M(I+1)];
                            end
                        end
                        %Cache interpolations
                        Tr_interp = interp1(R_nu_shift,R_Tr,Df);
                        Tb_interp = interp1(R_nu_shift,R_Tb,Df);
                    else
                        local_sol(j) = Df(I);
                    end
    
                    if iter > 100 || diff(1) == diff(3)
                        if error <0.05
                            error = 0;
                            local_sol(j) = Df(1);
                        else
                            error = 0;
                            local_sol(j) = NaN;
                        end
                    end
        
                end
            end
        end
        sol(i, :) = local_sol;
        % toc(inner_tic)
        % disp(append('i = ',num2str(i)))
    end
    %store solution in the results structure
    Winds.Df_f(:,:,k) = sol;
end
toc

tic
for k = 1:Options.bootstrap_iterations
    C_M = Counts.M_g(:,:,k);
    BR = HSRL.BR_g(:,:,k);
    
    %preallocate the solution
    sol = NaN(size(C_M));
    parfor i = 1:Li
        % inner_tic = tic;
        local_sol = NaN(1,Lj);
        for j = 1:Lj
            if logic(i,j) == 1
                local_sol(j) = NaN;
            else
                error = 1;
                iter = 1;
                Df = [-1e9 0 1e9];
                %Cache interpolations
                Tr_interp = interp1(R_nu_shift,R_Tr,Df);
                Tb_interp = interp1(R_nu_shift,R_Tb,Df);
    
                M = NaN(1,length(Df));
                while error>1e-6
                    for h = 1:length(Df)
                        if isnan(M(h))
                            nu_shift_Df_h = A_nu_shift + Df(h);
                            Cabannes_interp = interp1(nu_shift_Df_h, squeeze(A_Cabannes(i,j,:)), A_nu_shift, 'linear', 'extrap');
                            
                            %% A1 and A2
                            A1 = (BR(i,j) - 1)*(Tr_interp(h)-Tb_interp(h));
                            A2 = (BR(i,j) - 1)*(Tr_interp(h)+Tb_interp(h));
                            
                            %% B1 and B2
                            B1 = trapz(A_nu_shift,Cabannes_interp.*Receiver_diff);
                            B2 = trapz(A_nu_shift,Cabannes_interp.*Receiver_sum);
                            
                            M(h) = (A1+B1)/(A2+B2);
                        end
                    end
                    diff = abs(C_M(i,j) - M);
                    [error,I] = min(diff);
                    iter = iter +1;
        
                    if error > 1e-6 
                        % Select new interval based on the error
                        if I == 1
                            Df = linspace(Df(1), Df(2), 3);
                            M = [M(1) NaN M(2)];
                        elseif I == length(Df)
                            Df = linspace(Df(end-1), Df(end), 3);
                            M = [M(end-1) NaN M(end)];
                        else
                            if C_M(i,j) > M(2)
                                Df = linspace(Df(I-1), Df(I), 3);
                                M = [M(I-1) NaN M(I)];
                            else
                                Df = linspace(Df(I), Df(I+1), 3);
                                M = [M(I) NaN M(I+1)];
                            end
                        end
                        %Cache interpolations
                        Tr_interp = interp1(R_nu_shift,R_Tr,Df);
                        Tb_interp = interp1(R_nu_shift,R_Tb,Df);
                    else
                        local_sol(j) = Df(I);
                    end
    
                    if iter > 100 || diff(1) == diff(3)
                        if error <0.05
                            error = 0;
                            local_sol(j) = Df(1);
                        else
                            error = 0;
                            local_sol(j) = NaN;
                        end
                    end
        
                end
            end
        end
        sol(i, :) = local_sol;
        % toc(inner_tic)
        % disp(append('i = ',num2str(i)))
    end
    %store solution in the results structure
    Winds.Df_g(:,:,k) = sol;
end
toc
end