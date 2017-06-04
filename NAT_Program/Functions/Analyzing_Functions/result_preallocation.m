function handles = result_preallocation(handles,cg)
% RESULT_PREALLOCATION
% Set the options for result preallocation for online analysis
% and for result saving. % Value of 1 turns on the preallocation
% function.

% Version:                 1.3
% Erstellt von:            Matej Rejc      - 17.04.2013
% Letzte Änderung durch:   Franz Zeilinger - 11.09.2013

% Access to the data-Object:
d = handles.NAT_Data;
% how many data_sets are in the current input data available:
num_data_set = handles.Current_Settings.Simulation.Number_Runs;

% Online analysis function preallocations **
% Online voltage violation analysis will be performed.
voltage_violation_analysis = handles.Current_Settings.Simulation.Voltage_Violation_Analysis;
% Online Branch violation analysis will be performed.
branch_violation_analysis = handles.Current_Settings.Simulation.Branch_Violation_Analysis;
% Online active power loss analysis will be perfomed
grid_power_loss_analysis = handles.Current_Settings.Simulation.Power_Loss_Analysis;


% Result preallocation **
% Voltage results will be saved.
save_voltage_results = handles.Current_Settings.Simulation.Save_Voltage_Results ;
% Branch results (from node to element) will be saved.
save_branch_results = handles.Current_Settings.Simulation.Save_Branch_Results; % Save branch results
% Power loss results will be saved in W.
save_ploss_results = handles.Current_Settings.Simulation.Save_Power_Loss_Results; % Save branch results

% ---------------------------------------------------------------------------
% Result preallocation procedure - Voltage violation analysis
% ---------------------------------------------------------------------------
if voltage_violation_analysis == 1
	% Assumption: All datasets have the same number of timepoints
	d.Result.(cg).Voltage_Violation_Analysis(...
		1:num_data_set,...
		1:handles.Current_Settings.Simulation.Timepoints,...
		1:numel(d.Grid.(cg).All_Node.Points)) = ...
		zeros(num_data_set,...
		handles.Current_Settings.Simulation.Timepoints,...
		numel(d.Grid.(cg).All_Node.Points) );
	
	% Determine voltage limits within the online analysis
	d.Simulation.Voltage_Violation_Analysis.node_rated_voltages = ...
		vertcat(d.Grid.(cg).All_Node.Points.Rated_Voltage_phase_earth);
	% Recalculate voltage limits in p.u.
	d.Simulation.Voltage_Violation_Analysis.voltage_limit_values_pu = ...
		vertcat(d.Grid.(cg).All_Node.Points.Voltage_Limits)/100;
	% voltage_limits defined as 2 element matrix
	% [upper_U_limit  lower_U_limit]
	
end

% ---------------------------------------------------------------------------
% Result preallocation procedure - Branch violation analysis
% ---------------------------------------------------------------------------
if branch_violation_analysis == 1
	% Elements (lines and transformers) are merged
	% NOTE: LINES ARE ALWAYS FIRST, THEN COME THE 2W TRANSF!
	d.Result.(cg).Branch_Violation_Analysis(...
		1:num_data_set,...
		1:handles.Current_Settings.Simulation.Timepoints,...
		1: numel(d.Grid.(cg).Branches.Grouped) ) = ...
		zeros(num_data_set,...
		handles.Current_Settings.Simulation.Timepoints,...
		numel(d.Grid.(cg).Branches.Grouped) );
	
	% Line limits are in most cases given in A, therefore we will check
	% limit values by comparing I to Ilim
	d.Simulation.Branch_Violation_analysis.element_type = vertcat(d.Grid.(cg).Branches.Grouped.Branch_Type_ID);
	% d.Simulation.Branch_Violation_analysis.element_type is 1 if element is a line or 2 if element is a
	% 2w transformer
	
	d.Simulation.Branch_Violation_analysis.line_current_limits = vertcat(d.Grid.(cg).Branches.Lines.Current_Limits);
	% Transf. limits are in most cases given in VA, therefore we will check
	% limit values by comparing S to Smax
	d.Simulation.Branch_Violation_analysis.transf_app_power_limits = vertcat(d.Grid.(cg).Branches.Transf.App_Power_Limits);
	
	d.Simulation.Branch_Violation_analysis.branch_limits = ...
		[d.Simulation.Branch_Violation_analysis.line_current_limits;
		d.Simulation.Branch_Violation_analysis.transf_app_power_limits];
	% d.Simulation.Branch_Violation_analysis.branch_limits has the
	% limits to all branch elements - WARNING: the values here
	% should only be used in conjunction with
	% "d.Simulation.Branch_Violation_analysis.element_type",
	% as the values are not the same unit (Amps for lines, VA for
	% transformers) !!
end

% ---------------------------------------------------------------------------
% Result preallocation procedure - Power loss analysis
% ---------------------------------------------------------------------------
if grid_power_loss_analysis == 1
	% Voltage level of branches - numerical ID (from node)
	voltage_level_branch_ids = vertcat(d.Grid.(cg).Branches.Grouped.Voltage_Level_ID);
	% Voltage level of branches - value (from node)
	voltage_level_branch_val = vertcat(d.Grid.(cg).Branches.Grouped.Rated_Voltage1_phase_phase);
	
	% List of all voltage level ids
	[list_of_voltage_level_ids, idx] = ...
		unique(voltage_level_branch_ids);
	list_of_voltage_level_val = voltage_level_branch_val(idx);
	
	
	for i = 1 : numel(list_of_voltage_level_ids)
		branch_at_voltage_level{i} = ...
			find(voltage_level_branch_ids == list_of_voltage_level_ids(i));
		branch_voltage_level_id(i) = list_of_voltage_level_ids(i);
		branch_voltage_level_val(i) = list_of_voltage_level_val(i);
		
		% branch_at_voltage_level{i} is a cell array where numerical
		% values of branches that belong to the i-th voltage level are
		
		% branch_voltage_level_id is the list of all voltage level ids,
		% i.e. 1st, 2nd, ..., i-th, ...n-th voltage level id
		
		% branch_voltage_level_val is the list of rated voltage levels
		% for the i-th voltage level id
	end
	
	% Write branch voltage levels into the d.Grid.(cg).Branches
	d.Grid.(cg).Branches.grouped_voltage_level_id = branch_voltage_level_id;
	d.Grid.(cg).Branches.grouped_voltage_level_val = branch_voltage_level_val;
	d.Grid.(cg).Branches.grouped_branches_at_voltage_level = branch_at_voltage_level;
	
	% Preallocate the result arrays
	% 3rd dimension is [voltage level 1, voltage level 2, ... , voltage
	% level n, entire grid!]
	d.Result.(cg).Power_Loss_Analysis(...
		1:num_data_set,...
		1:handles.Current_Settings.Simulation.Timepoints,...
		1:(numel(d.Grid.(cg).Branches.grouped_voltage_level_id)+1)) = ...
		zeros(num_data_set,...
		handles.Current_Settings.Simulation.Timepoints,...
		(numel(d.Grid.(cg).Branches.grouped_voltage_level_id)+1));
	
end

% ---------------------------------------------------------------------------
% Result preallocation procedure - Save voltage results
% ---------------------------------------------------------------------------
if save_voltage_results == 1
	d.Result.(cg).Node_Voltages(...
		1:num_data_set,...
		1:handles.Current_Settings.Simulation.Timepoints,...
		1:numel(d.Grid.(cg).All_Node.Points),...
		1:3) = ...
		zeros(num_data_set,...
		handles.Current_Settings.Simulation.Timepoints,...
		numel(d.Grid.(cg).All_Node.Points),3);  % Three phase values
end

% ---------------------------------------------------------------------------
% Result preallocation procedure - Save branch results
% ---------------------------------------------------------------------------
if save_branch_results == 1
	% Branch_Values include both lines and 2w transformers
	d.Result.(cg).Branch_Values(...
		1:num_data_set,...
		1:handles.Current_Settings.Simulation.Timepoints,...
		1:numel(d.Grid.(cg).Branches.Grouped),...
		1:16) = ...
		zeros(num_data_set,...
		handles.Current_Settings.Simulation.Timepoints,...
		numel(d.Grid.(cg).Branches.Grouped),16);
end

% ---------------------------------------------------------------------------
% Result preallocation procedure - Save power loss results
% ---------------------------------------------------------------------------
if save_ploss_results == 1
	% Branch_Values include both lines and 2w transformers
	d.Result.(cg).Power_Loss_Values(...
		1:num_data_set,...
		1:handles.Current_Settings.Simulation.Timepoints,...
		1:numel(d.Grid.(cg).Branches.Grouped),...
		1) = ...
		zeros(num_data_set,...
		handles.Current_Settings.Simulation.Timepoints,...
		numel(d.Grid.(cg).Branches.Grouped),1);
	% <numb. of sets, numb. of timepoints,numb_of_branches,loss value>
end
end

