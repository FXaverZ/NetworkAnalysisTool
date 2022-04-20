function handles = call_electric_losses_time_graph(handles,inp)

% Do the results exist
if ~isfield(handles,'NVIEW_Processed')
    return;
end

% Transfer handles substructures to internal structures
d = handles.NVIEW_Processed;

Analysis_Selection_Id = define_analysis_selection_id(handles.NVIEW_Analysis_Selection);

% UI Table results update
if ~strcmp(handles.System.Graphics.Table,['Loss analysis_',Analysis_Selection_Id])
    handles = clear_table_results(handles);  
    Table = create_loss_table(handles,d);
    handles = draw_table(handles,Table);
end


Data_List = d.Control.Simulation_Description.Variants;

if inp == 1
    % Format table
    Table_per_grid = create_electric_losses_time_table_per_grid(d,Data_List)
    % Plot for all datasets
    handles = plot_timeline_graph(handles,Table_per_grid,Data_List);
elseif inp == 2
    % Format table    
    Table_per_scenario = create_electric_losses_time_table_per_scenario(d,Data_List);
    % Plot for all datasets
    handles = plot_timeline_graph(handles,Table_per_scenario,Table_per_scenario.Fields);
elseif inp == 3
    % Format table
    Table_per_grid_sum = create_electric_losses_sum_time_table_per_grid(d,Data_List);
    % Plot for all datasets
    handles = plot_timeline_graph_average(handles,Table_per_grid_sum,Data_List);
elseif inp == 4
    % Format table
    Table_per_scenario_sum = create_electric_losses_sum_time_table_per_scenario(d,Data_List);
    % Plot for all datasets
    handles = plot_timeline_graph_average(handles,Table_per_scenario_sum,Table_per_scenario_sum.Fields);


end

    