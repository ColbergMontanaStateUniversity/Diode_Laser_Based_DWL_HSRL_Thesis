% This code will generate the training set for the PCA analysis
% It will also perform the PCA
clear all; close all;

home = pwd;

%% user inputs
% What is the dimension of the output table (N x N x N)
N_atm = 200;
N_x = 10001; %make sure that this is odd

%What is the laser wavelength
lambda=780.2465e-9;

% create the temperature and pressure values to generate
T = linspace(100,400,N_atm); %K
P = linspace(10,1200,N_atm); %hPa (mbar)

%enter the folder containing the Tenti-s6 code
cd("Tenti_s6_code")

% preallocate the variables 
Y = zeros(N_atm,N_atm);
X = linspace(-15,15,N_x);
nushift = zeros(N_x,N_atm,N_atm);
Cabannes = zeros(N_x,N_atm,N_atm);

%%
% initiate the parfor loop (loop i over temperature; loop j over pressure)
p = gcp('nocreate'); % If no pool, do not create new one.
if isempty(p)
   p = parpool('local');
end


L = length(P);
tic
for i = 1:length(T)
    for j = 1:L
        
        %% This portion of the code was downloaded from https://www.mathworks.com/matlabcentral/fileexchange/29108-coherent-spontaneous-rayleigh-brillouin-scattering-spectra
        % This code was adapted and modified for dry air 
        % (instead of diatomic nitrogen) 
        % a fictitious gas with the average properties of dry air was used as the
        % gas in a similar manner to the German (DLR) airborne HSRL group
        
        % Sets and computes all relevant parameters
        % for s6 and s7 models given in Xingguo Pan's
        % dissertation entitled "Coherent Rayleigh-
        % Brillouin Scattering", 2003, Princeton Univ.
        
        % set the temperature of the gas
        tem=T(i); %K
        p_atm=P(j)/1013.25; %atm
        
        % create the domain of xi
        xi=linspace(-15,15,N_x);
        % 'xi' is dimensionless and should be scaled by k*v0/(2*pi) [Hz],
        % where 'v0' is the most probable gas velocity, or sqrt(2*kb*T/m),
        % and 'k' is 4*pi/lambda*sin(scatter_angle/2)
        % ***
        
        % set fundamental constants
        kb=1.380649e-23; %Joules/K
        
        % set laser parameters
        scatter_angle=pi; % pure backscatter
        k=4*pi/lambda*sin(scatter_angle/2);
        
        % set dry air properties
        m_m=28.966e-3 / 6.022140857e23; % mass in kg/molecule
        
        %Sutherland Equation
        mu0=1.733e-5; %kg/(m*s) reference shear viscosity
        Seta=110.4; %K
        T0=273.15; %K reference temperature
        shear_visc=mu0*(tem/T0)^(3/2) * ((T0+Seta)/(tem+Seta));  %kg/(m*s)
        
        lambda0=0.0242; %W/(K*m) reference thermal conductivity
        therm_cond=lambda0*(tem/T0)^0.76; %W/(K*m)
        
        gamma = 1.4; %adiabatic constant
        rho =((p_atm*101325)*28.966/1000)/(8.314471*tem); % density of air kg/m^3
        c_sound = sqrt(gamma*p_atm*100000/rho); % speed of sound in m/s
        bulk_visc=shear_visc*0.73;  %kg/(m*s), this is a poor approximation, but no better one could be found
        
        c_int=1; % dinmensionless internal specific heat capacity
        
        
        % compute most probable gas velocity
        v0=sqrt(2*kb*tem/m_m);
        % % % 
        % % % % convert pressures and densities
        p_pa=p_atm*1.01325e5;
        % % % p_torr=p_pa*0.00750061683;
        n0=p_pa/(tem*kb);
        
        % Dont change this section of the  code
        % compute and set RBS model input parameters
        c_tr=3/2;
        y=n0*kb*tem/(k*v0*shear_visc);
        gamma_int=c_int/(c_tr+c_int);
        rlx_int=1.5*bulk_visc/(shear_visc*gamma_int);
        eukenf=m_m*therm_cond/(shear_visc*kb*(c_tr+c_int));
        
        % run the code
        [~,sptsig6]=crbs6(y,rlx_int,eukenf,c_int,c_tr,xi);
        
        if mod(N_x, 2) == 1
            sptsig6(floor(length(sptsig6) / 2) + 1) = sptsig6(floor(length(sptsig6) / 2));
        end
        %save Y
        Y(i,j) = y;

        %save the signal
        Cabannes(:,i,j) = sptsig6;

        %save the real frequency
        nushift(:,i,j)=xi*k*v0/(2*pi);
        
    end
    disp(i)
end

% sort the profiles by ascending Y
disp("Sorting the profiles")
[Y_sorted,I_sorted] = sort(Y(:),'ascend');
I = zeros(size(Y));
parfor ii = 1: length(I(1,:))
    for jj = 1: L
        I(ii,jj) = find(Y(ii,jj) == Y_sorted);
    end
end

% sort the signal by ascending Y
Cabannes_sorted = zeros(N_atm*N_atm,N_x); 
nushift_sorted = zeros(N_atm*N_atm,N_x); 

for ii = 1: length(I(:,1))
    for jj = 1: length(I(1,:))   
        Cabannes_sorted(I(ii,jj),:) = Cabannes(:,ii,jj);
        nushift_sorted(I(ii,jj),:) = nushift(:,ii,jj);
    end
end


%% Plotting
% create surface plot
if N_atm>50
    div = round(N_atm/50);
else
    div = 1;
end

if N_x>500
    div2 = round(N_x/500);
else
    div2 = 1;
end

cd(home)
cd('..')
cd("Colormaps/Colormaps")
cm_viridis=viridis(100);
cd(home)

figure(1)
surf(repmat(X(1:div2:end),length(Y_sorted(1:div:end)),1),repmat(Y_sorted(1:div:end),1,length(X(1:div2:end))),Cabannes_sorted((1:div:end),(1:div2:end)));
colormap(cm_viridis)
shading interp

% intrepolate the data to a constant nushift grid
nu_shift = linspace(-7.5e9,7.5e9,N_x);
C = zeros(size(Cabannes));
parfor i = 1:length(T)
    for j =1:L
        temp = interp1(nushift(:,i,j),Cabannes(:,i,j),nu_shift);
        % normalize the signal so that the area is 1
        C(:,i,j) = temp/trapz(nu_shift,squeeze(temp));
    end
end

% intrepolate the sorted data to a constant nushift grid
C_sorted = zeros(size(Cabannes_sorted));
parfor i = 1:length(Y_sorted)
   C_sorted(i,:) = interp1(nushift_sorted(i,:),Cabannes_sorted(i,:),nu_shift);
end

figure(2)
surf(repmat(nu_shift(1:div2:end),length(Y_sorted(1:div:end)),1),repmat(Y_sorted(1:div:end),1,length(X(1:div2:end))),C_sorted((1:div:end),(1:div2:end)));
colormap(cm_viridis)
shading interp

cd(home)

clear Y_sorted C_sorted Cabannes Cabannes_sorted cm_viridis div div2 I...
    I_sorted ii jj L lambda N_atm N_x nushift nushift_sorted p X Y
Y = C;
clear C

mu_T = mean(T);
std_T = std(T);
Tn = (T - mu_T)/std_T;

mu_P = mean(P);
std_P = std(P);
Pn = (P - mu_P)/std_P;

%create a 2 column vector TP where TPn(:,1) contains the N0rmalized 
%temperature and TPn(:,2) contains the N0rmalized pressure
N = length(T);
TPn = zeros(N*N,2);
increment = 1;
for i = 1:N
    for j = 1:N
        TPn(increment,1) = Tn(i);
        TPn(increment,2) = Pn(j);
        increment = increment+1;
    end
end

% construct a Y vector
Y_vector = zeros(length(nu_shift),N*N);
increment = 1;
for i = 1:N
    for j = 1:N
        Y_vector(:,increment) = Y(:,i,j);
        increment = increment + 1;
    end
end

%Create theta based on T and P
N0 = 20;
theta = zeros(sum(N0:-1:0),N*N);

for j = 1:N*N
    inc=1;
    for n = 1:N0
        for m = 1:n
            theta(inc,j) = TPn(j,1)^(n-m) * TPn(j,2)^(m-1);
            inc=inc+1;
        end
    end
end

mu_Y = mean(Y_vector,2);
[U,~,~] = svd(Y_vector,"econ"); 
W = U'*(Y_vector-mu_Y);
C = W*pinv(theta);
M = U*C;

% save the principal components + the mean and standard deviations
PCA.M     = M;
PCA.N0    = N0;
PCA.mu_P  = mu_P;
PCA.mu_T  = mu_T;
PCA.mu_Y  = mu_Y;
PCA.std_P = std_P;
PCA.std_T = std_T;
PCA.nu_shift = nu_shift;

%% Saving
save("PCA780_2465nm_7_5GHz_20.mat","PCA")
toc