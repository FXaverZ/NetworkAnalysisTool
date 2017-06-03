clear; clc; close all; clear classes
% Warning: NAT post processing classes must be loaded!
filepath = 'D:\NAT_ISGT_Paper_Campaign\03_ISGT_Paper_Campaign\Results';
filename = 'Res_2013-05-17_15-36-03 - information.mat';
d = Loss_Post_Processing([filepath,filesep,filename]);

% ----------
scen = 3; grid = 1; set = 1; branch = 16;

% ----------
[table_results,xls_results] = d.compare_datasets(scen,grid,'xls');
% xlswrite('brtest1.xlsx',xls_results.sheet1,['S', int2str(scen), ' G', int2str(grid), ' Summary']);

[table_results,xls_results] = d.compare_grids(scen,'xls');
% xlswrite('brtest1.xlsx',xls_results.sheet1,['S', int2str(scen), ' Grids summary']);

[table_results,xls_results] = d.compare_grids_all_scenarios('xls');
% xlswrite('brtest1.xlsx',xls_results.sheet1,'Scenario-Grid summary');

%----------
% Plot horizontal bar comparison of datasets for scen and grid
d.display_datasets(scen,grid);
% Plot horizontal bar comparison of different grids for selected scenario
d.display_grids(scen);
% Plot horizontal bar comparison of different grids and different scenarios
d.display_grids_all_scenarios;

%----------

d.histogram_comparisons_grids_at_scenario(scen,'nan'); 
d.histogram_comparisons_scenarios_at_grid(grid,'nan');
