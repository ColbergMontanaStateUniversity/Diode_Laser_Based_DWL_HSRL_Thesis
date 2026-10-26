function [Container] = LoadContainer(foldername,Path)
% this function extracts the Container netCDF files from the raw 
% data folder

% inputs
% foldername - a string containing the name of the folder that contains
% the netCDF files
% Path - a structure containing the file paths

% outputs
% Container -  a structure containing the data stored in the Container  
% netCDF files containing the following variables:
% Container.time - Fractional days since Jan. 1. 2000
% Container.FunctionType - Type of function reporting status
% Container.CQueueEl - Number of elements currently reported in the child  
% command queue
% Container.RQueueEl - Number of elements currently reported in the child
% response queue
% Container.Status - Status of the child. Bit tested with the order: Child
% exiting, Child Commanded Stop, Child Responding

% store the current folder as a variable
home = pwd;

%navigate to the folder containing the raw data
cd(Path.RawData)
cd(foldername)

%create a directory of the pertinent files
Directory = dir('Container*.nc');

% load in the time through concatenation
Container.time = [];
for i = 1:length(Directory)
    Container.time =[Container.time;h5read(Directory(i).name,'/time')];
end

% preallocate the other variables
Container.FunctionType = strings(size(Container.time));
Container.CQueueEl     = zeros  (size(Container.time),'single');
Container.RQueueEl     = zeros  (size(Container.time),'single');
Container.Status       = zeros  (size(Container.time),'single');

% load in the other variables using a for loop with a counter
counter = 1;
for i = 1:length(Directory)

    FunctionType = h5read(Directory(i).name,'/FunctionType');
    Container.FunctionType(counter:counter+length(FunctionType)-1,:) = FunctionType;

    CQueueEl     = h5read(Directory(i).name,'/CQueueEl');
    Container.CQueueEl    (counter:counter+length(CQueueEl)-1,:)     = CQueueEl;
 
    RQueueEl     = h5read(Directory(i).name,'/RQueueEl');
    Container.RQueueEl    (counter:counter+length(RQueueEl)-1,:)     = RQueueEl;

    Status       = h5read(Directory(i).name,'/Status');
    Container.Status      (counter:counter+length(Status)-1,:)       = Status;

    counter = counter + length(FunctionType(:,1)) - 1;

end

% clear unnecessary variables
clear Directory FunctionType CQueueEl RQueueEl Status counter i

% navigate back to the home folder
cd(home)

end