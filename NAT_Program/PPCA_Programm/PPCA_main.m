clear; clc; close all; clear classes

filepath = 'C:\NAT_Second_Campaign\02_Simulation_Campaign\Results';
filename = 'Res_2013-05-15_18-03-43 - information.mat';

% filepath = 'E:\NAT_Second_Campaign\02_Simulation_Campaign\Results';
% filename = 'Res_2013-05-15_18-03-43 - information.mat';
d = Voltage_Post_Processing1([filepath,filesep,filename]);
d.Result_Filepath='C:\NAT_Second_Campaign\02_Simulation_Campaign\Results';
d.Scenario_Filepath='C:\NAT_Second_Campaign\02_Simulation_Campaign\Results';

d.Result_Files.Result_Filepath=d.Result_Filepath; 
d.Result_Files.Scenario_Filepath=d.Scenario_Filepath;
% ----------
scen = 3; grid = 2; set = 1; node = 6;

% ----------
[table_results,xls_results] = d.compare_datasets(scen,grid,'xls');
xlswrite('test3.xlsx',xls_results.sheet1,['S', int2str(scen), ' G', int2str(grid), ' Summary']);
xlswrite('test3.xlsx',xls_results.sheet2,['S', int2str(scen), ' G', int2str(grid), ' Load Infeed values']);

[table_results,xls_results] = d.compare_grids(scen,'xls');
xlswrite('test3.xlsx',xls_results.sheet1,['S', int2str(scen), ' Grids summary']);
xlswrite('test3.xlsx',xls_results.sheet2,['S', int2str(scen), ' Grids datasets']);

[table_results,xls_results] = d.compare_grids_all_scenarios('xls');
xlswrite('test3.xlsx',xls_results.sheet1,'Scenario-Grid summary');
xlswrite('test3.xlsx',xls_results.sheet2,'Scenario-Grid set comparison');

%----------
% Plot horizontal bar comparison of datasets for scen and grid
d.display_datasets(scen,grid);
% Plot horizontal bar comparison of different grids for selected scenario
d.display_grids(scen);
% Plot horizontal bar comparison of different grids and different scenarios
d.display_grids_all_scenarios;

%----------

[table_results,xls_results] = d.display_node_voltage(scen,grid,set,node,'xls');
xlswrite('test3.xlsx',xls_results.sheet1,'Node voltage');

d.display_node_variations_datasets(scen,grid,set,'plot');
d.display_node_variations_datasets(scen,grid,'all','plot');
d.display_node_variations_scenarios(grid,'plot');
d.display_node_variations_grids('plot');

%----------
d.histogram_comparisons_grids_at_scenario(scen);
d.histogram_comparisons_scenarios_at_grid(grid);

d.histogram_comparisons_inputs_at_scenarios;