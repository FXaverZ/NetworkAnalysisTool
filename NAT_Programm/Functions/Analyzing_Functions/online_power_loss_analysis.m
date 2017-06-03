function handles = online_power_loss_analysis(handles)

% Version:                 1.0
% Erstellt von:            Matej Rejc      - 29.04.2013
% Letzte Änderung durch:   

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

%-------------------------------------------------------------------
% Online active power loss analysis for unsymetric load flow
%-------------------------------------------------------------------
% Updat from and to active power flows on all branches
d.Grid.(cg).Branches.Grouped.update_power_branch_LF_USYM_to;
% active power losses defined as the difference between flow into the
% element and flow out of the element 
active_power_from = vertcat(d.Grid.(cg).Branches.Grouped.Active_Power);
active_power_to = vertcat(d.Grid.(cg).Branches.Grouped.Active_Power_to);

% One-phase representation of losses
active_power_from = sum(active_power_from(:,1:3),2);
active_power_to = sum(active_power_to(:,1:3),2);
active_power_losses = abs(active_power_from + active_power_to);



% Sum of all element losses
active_power_losses_at_grid = sum(active_power_losses);

for i = 1 : numel(d.Grid.(cg).Branches.grouped_voltage_level_id)
   active_power_losses_at_voltage_level(i) = sum(active_power_losses(...
       d.Grid.(cg).Branches.grouped_branches_at_voltage_level{i} ) );
end
       
% Write results into the preallocated array at (cd,ct,:) position
d.Result.(cg).Power_Loss_Analysis(cd,ct,:) = ...
    [active_power_losses_at_voltage_level,active_power_losses_at_grid];

% Save results of active power losses for each branch
if handles.Current_Settings.Simulation.Save_Branch_Results
    % Save active power losses in result structure
    d.Result.(cg).Power_Loss_Values(cd,ct,...
            1:numel(d.Grid.(cg).Branches.Grouped),...
            1) = active_power_losses;        
end

end


