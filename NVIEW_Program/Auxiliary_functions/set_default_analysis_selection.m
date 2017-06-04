function handles = set_default_analysis_selection(handles)

handles.NVIEW_Analysis_Selection = [];
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

% Default voltage violation limits
handles.NVIEW_Analysis_Selection.Umin = 90;  % 0.9 pu
handles.NVIEW_Analysis_Selection.Umax = 110; % 1.1 pu
handles.NVIEW_Analysis_Selection.Ilim = 100; % 100 %


% Set all branches and nodes for observation
for i = 1 : handles.NVIEW_Control.Simulation_Options.Number_of_Variants
    handles.NVIEW_Analysis_Selection.SelectedNodes.( handles.NVIEW_Control.Simulation_Description.Variants{i})(:,1) = ...
        ones(size(handles.NVIEW_Results.( handles.NVIEW_Control.Simulation_Description.Variants{i}).bus,1),1);

    handles.NVIEW_Analysis_Selection.SelectedBranches.( handles.NVIEW_Control.Simulation_Description.Variants{i})(:,1) = ...
        ones(size(handles.NVIEW_Results.( handles.NVIEW_Control.Simulation_Description.Variants{i}).branch,1),1);
end


end