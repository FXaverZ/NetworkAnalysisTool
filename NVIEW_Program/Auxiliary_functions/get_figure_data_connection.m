function [output,ident] = get_figure_data_connection(active_figure)

ident = [];
output = [];
% Headers
figure_data_id{1,1} = 'Time_load_infeed';
figure_data_id{2,1} = 'Average_Time_load_infeed';

figure_data_id{3,1} = 'Voltage_Violations_Timeline_Grid';
figure_data_id{4,1} = 'Voltage_Violations_Timeline_Scen';
figure_data_id{5,1} = 'Total_Voltage_Viol_Timeline_Grid';
figure_data_id{6,1} = 'Total_Voltage_Viol_Timeline_Scen';

figure_data_id{7,1} = 'Current_Violations_Timeline_Grid';
figure_data_id{8,1} = 'Current_Violations_Timeline_Scen';
figure_data_id{9,1} = 'Total_Current_Viol_Timeline_Grid';
figure_data_id{10,1} = 'Total_Current_Viol_Timeline_Scen';

figure_data_id{11,1} = 'Average_Branch_Loading_Timeline_Grid';
figure_data_id{12,1} = 'Average_Branch_Loading_Timeline_Scen';
figure_data_id{13,1} = 'Total_Average_Branch_Loading_Timeline_Grid';
figure_data_id{14,1} = 'Total_Average_Branch_Loading_Timeline_Scen';

figure_data_id{15,1} = 'Electrical_Losses_Timeline_Grid';
figure_data_id{16,1} = 'Electrical_Losses_Timeline_Scen';
figure_data_id{17,1} = 'Total_Electrical_Losses_Timeline_Grid';
figure_data_id{18,1} = 'Total_Electrical_Losses_Timeline_Scen';


% function menu_load_analysis_all_Callback
figure_name = get(active_figure,'Name');

if strcmp(figure_name,'Household active power consumption timeline') || strcmp(figure_name,'Solar power plants active power injection timeline') || strcmp(figure_name,'E-mobility active power consumption timeline') || strcmp(figure_name,'System balance active power timeline')
    output = 1;
elseif strcmp(figure_name,'Household average active power consumption timeline') || strcmp(figure_name,'Solar power plants average active power injection timeline') ||  strcmp(figure_name,'E-mobility average active power consumption timeline') || strcmp(figure_name,'System balance average active power timeline')
   output = 2;   
elseif strncmp(figure_name,'Voltage violations at',21) && strncmp(figure_name(end-7:end),'timeline',8)
    output = 3;
elseif strncmp(figure_name,'Voltage violations timeline at grids',36) 
    output = 4;
elseif strncmp(figure_name,'Total number of voltage violations at',37) && strncmp(figure_name(end-7:end),'timeline',8)
    output = 5;
elseif strncmp(figure_name,'Total number of voltage violations timeline for',47)
    output = 6;
elseif strncmp(figure_name,'Current violations at',21) && strncmp(figure_name(end-7:end),'timeline',8)
    output = 7;
elseif strncmp(figure_name,'Current violations timeline at grids',36) 
    output = 8;    
elseif strncmp(figure_name,'Total number of current violations at',37) && strncmp(figure_name(end-7:end),'timeline',8)
    output = 9;
elseif strncmp(figure_name,'Total number of current violations timeline for',47)
    output = 10;
elseif strncmp(figure_name,'Average branch loading at',25) && strncmp(figure_name(end-7:end),'timeline',8)
    output = 11;
elseif strncmp(figure_name,'Average branch loading timeline at grids for',44)    
    output = 12;
elseif strncmp(figure_name,'Average branch loading timeline for all datasets for',52)
    output = 13;
elseif strncmp(figure_name,'Average branch loading timeline for all datasets at',51) && strncmp(figure_name(end-7:end),'timeline',8)
    output = 14;    
elseif strncmp(figure_name,'Electric losses at',18) && strncmp(figure_name(end-7:end),'timeline',8)
    output = 15;
elseif strncmp(figure_name,'Electric losses timeline at grids for',37)
    output = 16;
elseif strncmp(figure_name,'Electric losses sum for all datasets at',39) && strncmp(figure_name(end-7:end),'timeline',8)
    output = 17;
elseif strncmp(figure_name,'Electric losses sum for all datasets timeline for',49)
    output = 18;
end

if ~isempty(output)
    ident = figure_data_id{output};
end

end