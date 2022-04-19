function handles = call_list_nodes_violated(handles)
% Voltage violation analysis subroutine

% Do the results exist
if ~isfield(handles,'NVIEW_Processed')
    return;
end

% Transfer handles substructures to internal structures
d = handles.NVIEW_Processed;

Analysis_Selection_Id = define_analysis_selection_id(handles.NVIEW_Analysis_Selection);

% Table output functions
violated_node_list = get_violated_node_list(d);

% UI Table results update
if ~strcmp(handles.System.Graphics.Table,['List_nodes_affected_',Analysis_Selection_Id])
    handles = clear_table_results(handles);  
    Table = create_list_nodes_violated_table(handles,d,violated_node_list);
    handles = draw_table(handles,Table);
end


end

