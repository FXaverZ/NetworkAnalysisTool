function handles = call_load_analysis(handles)
% Load/infeed analysis subroutine

Table_Inp = get_data_input_scenarios(handles);

% UI Table results update
if ~strcmp(handles.System.Graphics.Table,'Load/Infeed analysis')    
    handles = clear_table_results(handles);  
    Table = create_load_infeed_table(handles,Table_Inp);
    handles = draw_load_infeed_table(handles,Table);
end


% Call load/infeed analysis plots
histogram_data_input_scenarios(handles,Table_Inp);


end

