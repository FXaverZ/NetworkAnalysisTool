function handles = call_electric_losses_analysis(handles,selection_input)
% Voltage violation analysis subroutine

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

% Table output functions
electric_losses_overall = get_electric_losses_overall(d);
electric_losses_scenario = get_electric_losses_scenarios(d);

% Call voltage analysis plots
if selection_input == 0 % Show all    
    plot_electric_losses_overall(handles,electric_losses_overall);  
    plot_electric_losses_scenarios(handles,electric_losses_scenario);    
    histogram_electric_losses_overall(handles,d);
elseif selection_input == 1 % Show voltage violation numbers
    plot_electric_losses_overall(handles,electric_losses_overall);  
    plot_electric_losses_scenarios(handles,electric_losses_scenario);
elseif selection_input == 2 % Show histograms
    histogram_electric_losses_overall(handles,d);
elseif selection_input == -1 % Only table
    return;
end

end

