function handles = save_branch_values(handles)

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
element_type = d.Simulation.Branch_Violation_analysis.element_type;

%-------------------------------------------------------------
% Values saved in W, VAr, VA and A: [P1 Q1 S1 I1 P2 Q2 S2 I2 P3 Q3 S3 I3 Pe Qe Se Ie]
% (4 values per phase and phase-ground)

% Warning: Lines must always be before transformers!
% Save line branch values (P,Q,S,I for L1, L2, L3)
d.Grid.(cg).Branches.Lines.update_current_branch_LF_USYM;
line_currents = vertcat(d.Grid.(cg).Branches.Lines.Current);

if ~isempty(line_currents)
    d.Grid.(cg).Branches.Lines.update_power_branch_LF_USYM;
    line_active_power = vertcat(d.Grid.(cg).Branches.Lines.Active_Power);
    line_reactive_power = vertcat(d.Grid.(cg).Branches.Lines.Reactive_Power);
    line_apparent_power = vertcat(d.Grid.(cg).Branches.Lines.Apparent_Power);
    
    branch_values(element_type == 1,1:4:16) = line_active_power;
    branch_values(element_type == 1,2:4:16) = line_reactive_power;
    branch_values(element_type == 1,3:4:16) = line_apparent_power;
    branch_values(element_type == 1,4:4:16) = line_currents;
end

% Save transformer branch values (P,Q,S,I for L1, L2, L3)
d.Grid.(cg).Branches.Transf.update_current_branch_LF_USYM;
transf_currents = vertcat(d.Grid.(cg).Branches.Transf.Current);

if ~isempty(transf_currents)
    d.Grid.(cg).Branches.Transf.update_power_branch_LF_USYM;
    transf_active_power = vertcat(d.Grid.(cg).Branches.Transf.Active_Power);
    transf_reactive_power = vertcat(d.Grid.(cg).Branches.Transf.Reactive_Power);
    transf_apparent_power = vertcat(d.Grid.(cg).Branches.Transf.Apparent_Power);

    branch_values(element_type == 2,1:4:16) = transf_active_power;
    branch_values(element_type == 2,2:4:16) = transf_reactive_power;
    branch_values(element_type == 2,3:4:16) = transf_apparent_power;
    branch_values(element_type == 2,4:4:16) = transf_currents;
    % Values saved in W, VAr, VA and A: 
    % = [P1 Q1 S1 I1 P2 Q2 S2 I2 P3 Q3 S3 I3 Pe Qe Se Ie]
    % (4 values per phase and phase-ground)
end
% Values saved in W, VAr, VA and A: 
% = [P1 Q1 S1 I1 P2 Q2 S2 I2 P3 Q3 S3 I3 Pe Qe Se Ie]
% (4 values per phase and phase-ground)
d.Result.(cg).Branch_Values(cd,ct,:,:) = branch_values;
        
end
