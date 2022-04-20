function handles = call_load_time_graph(handles,inp)

% Do the results exist
if ~isfield(handles,'NVIEW_Processed')
    return;
end

% Transfer handles substructures to internal structures
d = handles.NVIEW_Processed;
d.Input_Data.Balance = (d.Input_Data.Households - d.Input_Data.Solar + d.Input_Data.El_mobility);

Analysis_Selection_Id = define_analysis_selection_id(handles.NVIEW_Analysis_Selection);

Table_Inp = get_data_input_scenarios(d);
% UI Table results update
if ~strcmp(handles.System.Graphics.Table,['Load/Infeed analysis_',Analysis_Selection_Id])
    handles = clear_table_results(handles);
    Table = create_load_infeed_table(d,Table_Inp);
    handles = draw_table(handles,Table);
end

Data_List = fields(d.Input_Data);

if inp == 1
    % Format table
    Table = create_load_time_table(d,Data_List);
    % Plot for all datasets
    handles = plot_timeline_graph(handles,Table,Data_List);
elseif inp == 2
    % Format table
    Table_average = create_average_load_time_table(d,Data_List);
    % Plot for average datasets
    handles = plot_timeline_graph_average(handles,Table_average,Data_List);
end