function handles = call_current_violation_time_graph(handles,inp)

% Transfer handles substructures to internal structures
d = handles.NVIEW_Processed;
Data_List = setdiff(fields(d),[{'Input_Data'},{'Control'}]);

Analysis_Selection_Id = define_analysis_selection_id(handles.NVIEW_Analysis_Selection);

% UI Table results update
if ~strcmp(handles.System.Graphics.Table,['Current analysis_',Analysis_Selection_Id])
    handles = clear_table_results(handles);
    Table = create_current_table(handles,d);
    handles = draw_table(handles,Table);
end


if inp == 1
    % Format table
    Table_per_grid = create_current_violation_time_table_per_grid(d,Data_List);
    % Plot for all datasets
    handles = plot_timeline_graph(handles,Table_per_grid,Data_List);
    
elseif inp == 2
    % Format table
    Table_per_scenario = create_current_violation_time_table_per_scenario(d,Data_List);
    % Plot for all datasets
    handles = plot_timeline_graph(handles,Table_per_scenario,Table_per_scenario.Fields);
    
elseif inp == 3
    % Format table
    Table_per_grid_sum = create_current_violation_sum_time_table_per_grid(d,Data_List);
    % Plot for all datasets
    handles = plot_timeline_graph_average(handles,Table_per_grid_sum,Data_List);
    
elseif inp == 4
    % Format table
    Table_per_scenario_sum = create_current_violation_sum_time_table_per_scenario(d,Data_List);
    % Plot for all datasets
    handles = plot_timeline_graph_average(handles,Table_per_scenario_sum,Table_per_scenario_sum.Fields);
    
elseif inp == 5
    % Format table
    Table_loading_per_grid = create_branch_loading_time_table_per_grid(d,Data_List);
    % Plot for all datasets
    handles = plot_timeline_graph(handles,Table_loading_per_grid,Data_List);
    
elseif inp == 6
    % Format table
    Table_loading_per_scenario = create_branch_loading_time_table_per_scenario(d,Data_List);
    % Plot for all datasets
    handles = plot_timeline_graph(handles,Table_loading_per_scenario,Table_loading_per_scenario.Fields);
    
elseif inp == 7
    % Format table
    Table_loading_per_grid_total = create_branch_loading_total_time_table_per_grid(d,Data_List);
    % Plot for all datasets
    handles = plot_timeline_graph_average(handles,Table_loading_per_grid_total,Data_List);
    
elseif inp == 8
    Table_loading_per_scenario_total = create_branch_loading_total_time_table_per_scenario(d,Data_List);
    % Plot for all datasets
    handles = plot_timeline_graph_average(handles,Table_loading_per_scenario_total,Table_loading_per_scenario_total.Fields);
end