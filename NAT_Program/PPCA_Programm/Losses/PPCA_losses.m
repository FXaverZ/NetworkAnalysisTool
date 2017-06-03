clear; clc; close all; clear classes

filepath = 'D:\NAT_First_Campaign\First_Simulation_Campaign\Results';
filename = 'Res_2013-05-07_10-46-07 - information.mat';
d = Losses_Post_Processing([filepath,filesep,filename]);

% ----------
scen = 1; grid = 1; set = 1; node = 6;


d.compare_losses;