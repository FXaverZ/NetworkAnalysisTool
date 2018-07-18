function handles = save_branch_values(handles)

% Version:                 1.1
% Erstellt von:            Matej Rejc - 14.03.2013
% Letzte Änderung durch:   Franz Zeilinger - 04.12.2014

% Getting access to the data-object
d = handles.NAT_Data;
% this object represents a connection to the stored data within the NAT


% current time point (integer from 1 to number of timepoints to be
% simulated):
ct = d.Simulation.Current_timepoint;
% current simulated grid (grid name as string):
cg = d.Simulation.Grid_act;
% current active dataset (also as integers?):
cd = d.Simulation.Input_Data_act;

branch_values = zeros(numel(d.Simulation.Branch_Violation_analysis.element_type),16);
branch_values_to = branch_values;
element_type = d.Simulation.Branch_Violation_analysis.element_type;

%-------------------------------------------------------------
% Values saved in W, VAr, VA and A: [P1 Q1 S1 I1 P2 Q2 S2 I2 P3 Q3 S3 I3 Pe Qe Se Ie]
% (4 values per phase and phase-ground)

% Warning: Lines must always be before transformers!
% Save line branch values (P,Q,S,I for L1, L2, L3)
d.Grid.(cg).Branches.Lines.update_current_branch_LF_USYM;
d.Grid.(cg).Branches.Lines.update_current_branch_LF_USYM_to;
line_currents = vertcat(d.Grid.(cg).Branches.Lines.Current);
line_currents_to = vertcat(d.Grid.(cg).Branches.Lines.Current_to);

if ~isempty(line_currents)
    d.Grid.(cg).Branches.Lines.update_power_branch_LF_USYM;
    line_active_power = vertcat(d.Grid.(cg).Branches.Lines.Active_Power);
    line_reactive_power = vertcat(d.Grid.(cg).Branches.Lines.Reactive_Power);
    line_apparent_power = vertcat(d.Grid.(cg).Branches.Lines.Apparent_Power);
    
    branch_values(element_type == 1,1:4:16) = line_active_power;
    branch_values(element_type == 1,2:4:16) = line_reactive_power;
    branch_values(element_type == 1,3:4:16) = line_apparent_power;
    branch_values(element_type == 1,4:4:16) = line_currents(:,1:4);
	
	d.Grid.(cg).Branches.Lines.update_power_branch_LF_USYM_to;
    line_active_power = vertcat(d.Grid.(cg).Branches.Lines.Active_Power_to);
    line_reactive_power = vertcat(d.Grid.(cg).Branches.Lines.Reactive_Power_to);
    line_apparent_power = vertcat(d.Grid.(cg).Branches.Lines.Apparent_Power_to);
	
	branch_values_to(element_type == 1,1:4:16) = line_active_power;
	branch_values_to(element_type == 1,2:4:16) = line_reactive_power;
    branch_values_to(element_type == 1,3:4:16) = line_apparent_power;
    branch_values_to(element_type == 1,4:4:16) = line_currents_to(:,1:4);
end

% Save transformer branch values (P,Q,S,I for L1, L2, L3)
d.Grid.(cg).Branches.Transf.update_current_branch_LF_USYM;
d.Grid.(cg).Branches.Transf.update_current_branch_LF_USYM_to;
transf_currents = vertcat(d.Grid.(cg).Branches.Transf.Current);
transf_currents_to = vertcat(d.Grid.(cg).Branches.Transf.Current_to);

if ~isempty(transf_currents)
    d.Grid.(cg).Branches.Transf.update_power_branch_LF_USYM;
    transf_active_power = vertcat(d.Grid.(cg).Branches.Transf.Active_Power);
    transf_reactive_power = vertcat(d.Grid.(cg).Branches.Transf.Reactive_Power);
    transf_apparent_power = vertcat(d.Grid.(cg).Branches.Transf.Apparent_Power);

    branch_values(element_type == 2,1:4:16) = transf_active_power;
    branch_values(element_type == 2,2:4:16) = transf_reactive_power;
    branch_values(element_type == 2,3:4:16) = transf_apparent_power;
    branch_values(element_type == 2,4:4:16) = transf_currents(:,1:4);
    % Values saved in W, VAr, VA and A: 
    % = [P1 Q1 S1 I1 P2 Q2 S2 I2 P3 Q3 S3 I3 Pe Qe Se Ie]
    % (4 values per phase and phase-ground)
	
	d.Grid.(cg).Branches.Transf.update_power_branch_LF_USYM_to;
    transf_active_power = vertcat(d.Grid.(cg).Branches.Transf.Active_Power_to);
    transf_reactive_power = vertcat(d.Grid.(cg).Branches.Transf.Reactive_Power_to);
    transf_apparent_power = vertcat(d.Grid.(cg).Branches.Transf.Apparent_Power_to);

    branch_values_to(element_type == 2,1:4:16) = transf_active_power;
    branch_values_to(element_type == 2,2:4:16) = transf_reactive_power;
    branch_values_to(element_type == 2,3:4:16) = transf_apparent_power;
    branch_values_to(element_type == 2,4:4:16) = transf_currents_to(:,1:4);
end
% Values saved in W, VAr, VA and A: 
% = [P1 Q1 S1 I1 P2 Q2 S2 I2 P3 Q3 S3 I3 Pe Qe Se Ie]
% (4 values per phase and phase-ground)
d.Result.(cg).Branch_Values(cd,ct,:,:) = branch_values;
d.Result.(cg).Branch_Values_to(cd,ct,:,:) = branch_values_to;       
end
