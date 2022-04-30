function handles = call_current_analysis(handles,selection_input)
% Voltage violation analysis subroutine

% Do the results exist
if ~isfield(handles,'NVIEW_Processed')
    return;
end

% Transfer handles substructures to internal structures
d = handles.NVIEW_Processed;

Analysis_Selection_Id = define_analysis_selection_id(handles.NVIEW_Analysis_Selection);

% UI Table results update
if ~strcmp(handles.System.Graphics.Table,['Current analysis_',Analysis_Selection_Id])
    handles = clear_table_results(handles);  
    Table = create_current_table(handles,d);
    handles = draw_table(handles,Table);
end

% Table output functions
current_violations_numbers_overall = get_current_violation_numbers_overall(d);
current_violation_numbers_scenarios = get_current_violation_numbers_scenarios(d);
violated_branch_numbers_overall = get_violated_branch_numbers_overall(d);
violated_branch_numbers_scenarios = get_violated_branch_numbers_scenarios(d);
branch_loading_analysis_overall = get_branch_loading_analysis_overall(d);
branch_loading_analysis_scenarios = get_branch_loading_analysis_scenarios(d);

% Call voltage analysis plots
if selection_input == 0 % Show all    
    plot_current_violation_numbers_overall(handles,current_violations_numbers_overall);    
    plot_current_violation_numbers_scenarios(handles,current_violation_numbers_scenarios); 
    plot_violated_branch_numbers_overall(handles,violated_branch_numbers_overall);
    plot_violated_node_numbers_scenarios(handles,violated_branch_numbers_scenarios);
    histogram_current_violation_numbers_overall(handles,d);
    histogram_violated_branch_numbers_overall(handles,d);    
    plot_branch_loading_overall(handles,branch_loading_analysis_overall);
    plot_branch_loading_scenarios(handles,branch_loading_analysis_scenarios);

elseif selection_input == 1 % Show voltage violation numbers
    plot_current_violation_numbers_overall(handles,current_violations_numbers_overall);
    plot_current_violation_numbers_scenarios(handles,current_violation_numbers_scenarios);  
elseif selection_input == 2 % Show nodes affected by voltage violations
    plot_violated_branch_numbers_overall(handles,violated_branch_numbers_overall);
    plot_violated_node_numbers_scenarios(handles,violated_branch_numbers_scenarios);
elseif selection_input == 3 % Show histograms
    histogram_current_violation_numbers_overall(handles,d);
    histogram_violated_branch_numbers_overall(handles,d);
elseif selection_input == 4 % Show branch loading
    plot_branch_loading_overall(handles,branch_loading_analysis_overall);
    plot_branch_loading_scenarios(handles,branch_loading_analysis_scenarios);
elseif selection_input == -1 % Only table
    return;
end

end

