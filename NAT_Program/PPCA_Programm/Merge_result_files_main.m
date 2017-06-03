clear; clc; clear classes

filepath = 'D:\NAT_Second_Campaign\02_Simulation_Campaign\Results';
filenames{1} = 'Res_2013-05-15_18-03-43 - information.mat';
filenames{2} = 'Res_2013-05-15_18-39-41 - information.mat';
% add more filenames in cell form for merging...


m = Merge_Simulation_Results(filepath,filenames);
% merge files function checks the information files for parity, merges
% scenario information, renames scenario files based on the current
% timestamp, creates new information file and deletes old information files
m.merge_files;