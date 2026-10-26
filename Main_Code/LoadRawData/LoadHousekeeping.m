function [HKeep] = LoadHousekeeping(foldername,Path)

% store the current folder as a variable
home = pwd;

%navigate to the folder containing the raw data
cd(Path.RawData)
cd(foldername)

%create a directory of the pertinent files
Directory = dir('HKeep*.nc');

% load in the time through concatenation
HKeep.time = [];
for i = 1:length(Directory)
    HKeep.time =[HKeep.time;h5read(Directory(i).name,'/time')];
end


%preallocate the other variables
HKeep.Temperature = zeros(size(HKeep.time),'single');


%load through a counter and a for loop
counter=1;
for i=1:length(Directory)

    temp = h5read(Directory(i).name,'/Temperature');
    HKeep.Temperature (counter:counter+numel(temp(:,1))-1,:)  = temp(:,1);

    counter = counter+numel(temp(:,1))-1;
end
   
% navigate back to the home folder
cd(home)

end