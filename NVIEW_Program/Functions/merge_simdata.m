function data_merged = merge_simdata(handles, data_merged, data)
%MERGE_SIMDATA Summary of this function goes here
%   Detailed explanation goes here


% NOT FINISHED! JUST A TEST!


Grid_List = handles.NVIEW_Control.Simulation_Description.Variants;
Timepoints = handles.NVIEW_Control.Simulation_Options.Timepoints_per_dataset;
Datasets = handles.NVIEW_Control.Simulation_Options.Number_of_datasets;

if isempty(data_merged)
	for i = 1 : numel(Grid_List)
		if handles.NVIEW_Control.Simulation_Options.Voltage_Analysis == 1
			data_merged.Result.(Grid_List{i}).Voltage_Violation_Summary.Number_of_Violations = ...
				data.Result.(Grid_List{i}).Voltage_Violation_Summary.Number_of_Violations;
			data_merged.Result.(Grid_List{i}).Voltage_Violation_Summary.Number_of_Nodes_With_Violations = ...
				data.Result.(Grid_List{i}).Voltage_Violation_Summary.Number_of_Nodes_With_Violations;
		end
	end
end

for i = 1 : numel(Grid_List)
	if handles.NVIEW_Control.Simulation_Options.Voltage_Analysis == 1
	data_merged.Result.(Grid_List{i}).Voltage_Violation_Summary.Number_of_Violations = ...
		data.Result.(Grid_List{i}).Voltage_Violation_Summary.Number_of_Violations + ... 
	data.Result.(Grid_List{i}).Voltage_Violation_Summary.Number_of_Violations;
	end
end

end

