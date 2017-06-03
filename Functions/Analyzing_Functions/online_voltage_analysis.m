function handles = online_voltage_analysis(handles)
%ON_LINE_VOLTAGE_ANALAYSIS - voltage_analysis
%    This function represents the body of an anlayzing function for
%    "on-line" analyzing simulation results within the NAT.

%    This function has to know:
%      -  the current timepoint, which is simulated (e.g. time of day)
%      -  the used "set" of input values
%      -  the simulated grid variant
%      -  how the grid is organized within MATLAB (Grid representation in
%         MATLAB) in order to allow a mapping of the results. The Mapping
%         is done automatically, if the objects of the MATLAB Grid
%         representation (Structure "Grid") are used (see examples below) 

%    d.Result.(cg).Voltages (cd,ct,:,:)
%      -  Node voltages that can be stored in V or in percentages. 
%      -  1st dim. is dataset used, 2nd dim. is current timepoint, 3rd
%      -  dimension is node (row), 4th dimension is phase value (column)
%      %%%To be defined if we want to store voltages in this function or use a seperate function?
% 
%    d.Result.(cg).Voltage_Violation(cd,ct,:)
%      - Voltage limit exceeded condition array (on-line check)
%      - Values are either 0 (node voltage does not exceed limit), 1 (node
%      - voltage exceeds first limit) or 2 (node voltages exceed the second
%      - voltage limit). If both voltage limits are the same, values can
%      - either be 0 or 1
%      -  1st dim. is dataset used, 2nd dim. is current timepoint, 3rd
%      -  dimension is nodal condition value (row)

% Version:                 1.2 // -- changelog v1.1b ##### (all) // 20130418

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

%---- temporary (to define later)
% save_voltage_values = 1; % save voltage values in V
% % save_voltage_values = 2; % save voltage values in % (norm. on Urated)
save_voltage_values = 0; % do not save the values of node voltages
%---------


%-------------------------------------------------------------------
% Online voltage violation analysis for unsymetric load flow
%-------------------------------------------------------------------
        
% Update voltages at all nodes for unsymmetrical loadflow
d.Grid.(cg).All_Node.Points.update_voltage_node_LF_USYM;
% node_voltages sort the L1 L2 L3 voltages in a n x 3 array 
node_voltages = vertcat(d.Grid.(cg).All_Node.Points.Voltage);

% Determine voltage limits within the online analysis
% % d.Grid.(cg).All_Node.Points.define_voltage_limits; % <--------- 
    % If voltage limits will be changed during the
    % calculation phase, it is sensible to recheck the values, otherwise we
    % can only check the voltage limits once. (This can be accessed during 
    % on-line calculations or at the network_load start.) 
        
% Rated voltages of nodes (voltage level)
node_rated_voltages = vertcat(d.Grid.(cg).All_Node.Points.Rated_Voltage_phase_earth);

% Recalculate the voltages in p.u. (Ub = Urated)
node_voltages_pu = node_voltages ./ node_rated_voltages;

% Recalculate voltage limits in p.u.
voltage_limit_values_pu = vertcat(d.Grid.(cg).All_Node.Points.Voltage_Limits)/100;
% voltage_limits defined as 4 element matrix
% [upper_U_limit  lower_U_limit  upper_U_limit2   lower_U_limit2]


% Voltage_violation_check (T/F) array,  condition (u > umax  | u < umin ) is checked
% Voltage_violation_check2 (T/F) array, condition (u > umax2 | u < umin2) is checked 

voltage_violation_check  = node_voltages_pu > repmat(voltage_limit_values_pu(:,1),1,3) | ...  % upper voltage limit
                           node_voltages_pu < repmat(voltage_limit_values_pu(:,2),1,3);        % lower voltage limit
                       
voltage_violation_check2 = node_voltages_pu > repmat(voltage_limit_values_pu(:,3),1,3) | ...  % upper voltage limit 2
                           node_voltages_pu < repmat(voltage_limit_values_pu(:,4),1,3);       % lower voltage limit 2

% -- changelog v1.2 ##### (start) // 20130419
number_of_voltage_limits = vertcat(d.Grid.(cg).All_Node.Points.Number_of_Voltage_Violation_limits);
% -- changelog v1.2 ##### (end) // 20130419

% Voltage violation results are stored in structure
% d.Result.Grid_act.Voltage_Violation(cd,ct,:) is a 1 x node array
% Results are in (T/F) form:  0...no voltage limits exceeded, 
%                             1...first voltage limit exceeded
%                             2...both voltage limits exceeded

d.Result.(cg).Voltage_Violation(cd,ct,:) = ...
                            1*(sum(voltage_violation_check,2) > 0) +...
                            (number_of_voltage_limits - 1).*(sum(voltage_violation_check2,2) > 0);         
  
% Save voltage results ?
if save_voltage_values == 1
    d.Result.(cg).Voltages(cd,ct,:,:) = node_voltages; % Voltages saved in V values    
elseif save_voltage_values == 2
    d.Result.(cg).Voltages(cd,ct,:,:) = 100*node_voltages_pu; % Voltages saved in % values
end
  
     

end % End of function

