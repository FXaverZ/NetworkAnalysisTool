function handles = call_load_analysis(handles,selection_input)

if ~isfield(handles,'NVIEW_Processed')
    return;
end

% Load/infeed analysis subroutine

% Transfer handles substructures to internal structures
d = handles.NVIEW_Processed;

Analysis_Selection_Id = define_analysis_selection_id(handles.NVIEW_Analysis_Selection);

Table_Inp = get_data_input_scenarios(d);

% UI Table results update
if ~strcmp(handles.System.Graphics.Table,['Load/Infeed analysis_',Analysis_Selection_Id])
    handles = clear_table_results(handles);  
    Table = create_load_infeed_table(d,Table_Inp);
    handles = draw_table(handles,Table);
end

if selection_input == 1
    % Call load/infeed analysis plots
    histogram_data_input_scenarios(handles,d,Table_Inp);
else
    return;
end

end

