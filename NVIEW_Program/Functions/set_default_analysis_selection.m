function handles = set_default_analysis_selection(handles)
% Scenario default selection
handles.NVIEW_Analysis_Selection.Scenarios = ones(handles.NVIEW_Control.Simulation_Options.Number_of_Scenarios,1);
% Variant default selection
handles.NVIEW_Analysis_Selection.Variants  = ones(handles.NVIEW_Control.Simulation_Options.Number_of_Variants,1);
% Timepoint default selection
handles.NVIEW_Analysis_Selection.Timepoints = 1 : handles.NVIEW_Control.Simulation_Options.Timepoints_per_dataset;
handles.NVIEW_Analysis_Selection.Hours = 0 : 23;

SelectedTime_Id_Num = zeros(size(handles.NVIEW_Analysis_Selection.Hours));
SelectedTime_Id_Num(handles.NVIEW_Analysis_Selection.Hours+1) = 1;
handles.NVIEW_Analysis_Selection.SelectedTime_Id = strrep(int2str(SelectedTime_Id_Num),' ','');

handles.NVIEW_Analysis_Selection.DefaultTime_Id = handles.NVIEW_Analysis_Selection.SelectedTime_Id;
handles.NVIEW_Analysis_Selection.Appended_External_Results = 0;

end