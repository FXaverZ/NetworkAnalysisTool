clear; clc; close all; clear classes
% Warning: NAT post processing classes must be loaded!
filepath = 'D:\Projekte\Analysetool für NS-Netze\4_Netzanalysetool\NAT_Programm\Results';
filename = 'Res_2013-06-12_11-48-28 - information.mat';
d = Voltage_Post_Processing([filepath,filesep,filename]);

% ----------
scen = 1; grid = 1; set = 1; node = 1;

% ----------
[table_results,xls_results] = d.compare_datasets(scen,grid,'xls');
xlswrite('isgt_paper_comp.xlsx',xls_results.sheet1,['S', int2str(scen), ' G', int2str(grid), ' Summary']);
xlswrite('isgt_paper_comp.xlsx',xls_results.sheet2,['S', int2str(scen), ' G', int2str(grid), ' Load Infeed values']);

[table_results,xls_results] = d.compare_grids(scen,'xls');
xlswrite('isgt_paper_comp.xlsx',xls_results.sheet1,['S', int2str(scen), ' Grids summary']);
xlswrite('isgt_paper_comp.xlsx',xls_results.sheet2,['S', int2str(scen), ' Grids datasets']);

[table_results,xls_results] = d.compare_grids_all_scenarios('xls');
xlswrite('isgt_paper_comp.xlsx',xls_results.sheet1,'Scenario-Grid summary');
xlswrite('isgt_paper_comp.xlsx',xls_results.sheet2,'Scenario-Grid set comparison');

%----------
% Plot horizontal bar comparison of datasets for scen and grid
d.display_datasets(scen,grid);
% Plot horizontal bar comparison of different grids for selected scenario
d.display_grids(scen);
% Plot horizontal bar comparison of different grids and different scenarios
d.display_grids_all_scenarios;

%----------

[table_results,xls_results] = d.display_node_voltage(scen,grid,set,node,'xls');
xlswrite('isgt_paper_comp.xlsx',xls_results.sheet1,'Node voltage');

d.display_node_variations_datasets(scen,grid,set,'plot'); % to plot, the last input must be 'plot'
d.display_node_variations_datasets(scen,grid,'all','plot');
d.display_node_variations_scenarios(grid,'plot');
d.display_node_variations_grids('plot');

%----------
d.histogram_comparisons_grids_at_scenario(scen,'nan'); 
d.histogram_comparisons_scenarios_at_grid(grid,'nan');
d.histogram_comparisons_inputs_at_scenarios('nan');
% to ignore zeros, the last input must be 'nan'. Otherwise, no last input
% is used. % to change frequency/rel. frequency y values, plot_histogram object
% property must be changes
