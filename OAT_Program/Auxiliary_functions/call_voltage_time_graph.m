function handles = call_voltage_time_graph (handles,inp)
%CALL_VOLTAGE_TIME_GRAPH Summary of this function goes here
%   Detailed explanation goes here

% Transfer handles substructures to internal structures
d = handles.NVIEW_Processed;
Data_List = setdiff(fields(d),[{'Input_Data'},{'Control'}]);

Analysis_Selection_Id = define_analysis_selection_id(handles.NVIEW_Analysis_Selection);

% UI Table results update
if ~strcmp(handles.System.Graphics.Table,['Voltage analysis_',Analysis_Selection_Id])
    handles = clear_table_results(handles);  
    Table = create_voltage_violation_table(handles,d);
    handles = draw_table(handles,Table);
end

if inp == 1
    % Format table
    Table_per_grid_sum = create_voltage_mean_total_time_table_per_grid (d,Data_List);
    % Plot for all datasets
    handles = plot_timeline_graph_average(handles,Table_per_grid_sum,Data_List);
elseif inp == 2
	% Format table
	Table_per_grid = create_voltage_mean_time_table_per_grid(d,Data_List);
	% Plot for all datasets
    handles = plot_timeline_graph(handles,Table_per_grid,Data_List);
elseif inp == 3	
	% Format table
    Table_per_scenario_sum = create_voltage_mean_total_time_table_per_scenario (d,Data_List);
    % Plot for all datasets
    handles = plot_timeline_graph_average(handles,Table_per_scenario_sum,Table_per_scenario_sum.Fields);
elseif inp == 4	
	Table_per_scenario = create_voltage_mean_time_table_per_scenario (d,Data_List);
	% Plot for all datasets
    handles = plot_timeline_graph(handles,Table_per_scenario,Table_per_scenario.Fields);
elseif inp == 6
	% Format table
    Table_per_grid_sum = create_voltage_min_total_time_table_per_grid (d,Data_List);
	% Plot for all datasets
    handles = plot_timeline_graph_average(handles,Table_per_grid_sum,Data_List);
elseif inp == 7
	% Format table
	Table_per_grid = create_voltage_min_time_table_per_grid(d,Data_List);
	% Plot for all datasets
    handles = plot_timeline_graph(handles,Table_per_grid,Data_List);
elseif inp == 8
	% Format table
    Table_per_scenario_sum = create_voltage_min_total_time_table_per_scenario (d,Data_List);
    % Plot for all datasets
    handles = plot_timeline_graph_average(handles,Table_per_scenario_sum,Table_per_scenario_sum.Fields);
elseif inp == 9
	Table_per_scenario = create_voltage_min_time_table_per_scenario (d,Data_List);
	% Plot for all datasets
    handles = plot_timeline_graph(handles,Table_per_scenario,Table_per_scenario.Fields);
elseif inp == 10
	% Format table
    Table_per_grid_sum = create_voltage_max_total_time_table_per_grid (d,Data_List);
	% Plot for all datasets
    handles = plot_timeline_graph_average(handles,Table_per_grid_sum,Data_List);
elseif inp == 11
	% Format table
	Table_per_grid = create_voltage_max_time_table_per_grid(d,Data_List);
	% Plot for all datasets
    handles = plot_timeline_graph(handles,Table_per_grid,Data_List);
elseif inp == 12
	% Format table
    Table_per_scenario_sum = create_voltage_max_total_time_table_per_scenario (d,Data_List);
    % Plot for all datasets
    handles = plot_timeline_graph_average(handles,Table_per_scenario_sum,Table_per_scenario_sum.Fields);
elseif inp == 13	
	Table_per_scenario = create_voltage_max_time_table_per_scenario (d,Data_List);
	% Plot for all datasets
    handles = plot_timeline_graph(handles,Table_per_scenario,Table_per_scenario.Fields);
end

end

