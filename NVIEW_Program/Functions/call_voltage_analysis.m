function handles = call_voltage_analysis(handles,selection_input)
% Voltage violation analysis subroutine

% Transfer handles substructures to internal structures
d = handles.NVIEW_Results;
s = handles.NVIEW_Control;

% UI Table results update
if ~strcmp(handles.System.Graphics.Table,'Voltage analysis')
    handles = clear_table_results(handles);  
    Table = create_voltage_violation_table(handles,d,s);
    handles = draw_voltage_violation_table(handles,Table);
end

% Table output functions
voltage_violation_numbers_overall = get_voltage_violation_numbers_overall(handles,d,s);
voltage_violation_numbers_scenarios = get_voltage_violation_numbers_scenarios(handles,d,s);
violated_node_numbers_overall = get_violated_node_numbers_overall(handles,d,s);
violated_node_numbers_scenarios = get_violated_node_numbers_scenarios(handles,d,s);
node_voltage_deviations = get_node_voltage_deviations(handles,d,s);

% Call voltage analysis plots
if selection_input == 0 % Show all
    plot_voltage_violation_numbers_overall(handles,voltage_violation_numbers_overall);    
    plot_voltage_violation_numbers_scenarios(handles,voltage_violation_numbers_scenarios); 
    plot_violated_node_numbers_overall(handles,violated_node_numbers_overall);
    plot_violated_node_numbers_scenarios(handles,violated_node_numbers_scenarios);
    histogram_voltage_violation_numbers_overall(handles,d,s);
    histogram_violated_node_numbers_overall(handles,d,s);
    plot_node_voltage_deviations(handles,node_voltage_deviations);
elseif selection_input == 1 % Show voltage violation numbers
    plot_voltage_violation_numbers_overall(handles,voltage_violation_numbers_overall);    
    plot_voltage_violation_numbers_scenarios(handles,voltage_violation_numbers_scenarios); 
elseif selection_input == 2 % Show nodes affected by voltage violations
    plot_violated_node_numbers_overall(handles,violated_node_numbers_overall);
    plot_violated_node_numbers_scenarios(handles,violated_node_numbers_scenarios);
elseif selection_input == 3 % Show histograms
    histogram_voltage_violation_numbers_overall(handles,d,s);
    histogram_violated_node_numbers_overall(handles,d,s);
elseif selection_input == 4 % Show voltage deviations
    plot_node_voltage_deviations(handles,node_voltage_deviations);
end


end

