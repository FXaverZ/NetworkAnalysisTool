function handles = analyzing_function_1(handles)
%ANALYZING_FUNCTION_1    dummy of an analyzing function
%    This function represents the body of an anlayzing function for
%    "on-line" analyzing simulation results within the NAT.
%
%    This function has to know:
%      -  the current timepoint, which is simulated (e.g. time of day)
%      -  the used "set" of input values
%      -  the simulated grid variant
%      -  how the grid is organized within MATLAB (Grid representation in
%         MATLAB) in order to allow a mapping of the results. The Mapping
%         is done automatically, if the objects of the MATLAB Grid
%         representation (Structure "Grid") are used (see examples below) 

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


% Voltage_Violation_analysis value is used for preallocating the
% on-line result array
if ~isfield(d.Simulation, 'Voltage_Violation_analysis')
	d.Simulation.Voltage_Violation_analysis = 0;   
    % Voltage_Violation_analysis value is used for preallocating the
    % on-line result array
        % 0 ... no voltage violation analysis performed,
        % first preallocation for first active dataset
end
if ~isfield(d.Simulation, 'Voltage_Violation_limits')
    d.Simulation.Voltage_Violation_limits = 0;
    % Voltage_Violation_limits value is used to determine whether two
    % voltage limits are defined across all nodes    
        % 0 ... number of voltage limits not determined yet
end
%-------------------------------------------------------------------

% Check what type of simulation was performed and use appropriate functions
if strcmp(handles.Current_Settings.Simulation.Parameters(2),'LF_USYM') % Unsymetric load flow
        
    if d.Simulation.Voltage_Violation_analysis == 0  
        
        % d.Simulation.Voltage_Violation_analysis value is set to 1, i.e.
        % the first preallocation has been performed for the first active
        % dataset
        d.Simulation.Voltage_Violation_analysis = 1;   
        
        % If voltage violation array does not exist yet for this topology
        % model and for this Input_Data_act, preallocation of the array is performed 
        d.Result.Grid.(cg).Voltage_Violation(cd,:,:) = zeros(1,...
            handles.Current_Settings.Simulation.Timepoints,...
            numel(d.Grid.All_Node.Points));        
        
    elseif d.Simulation.Voltage_Violation_analysis == 1 & ...
            size(d.Result.Grid.(cg).Voltage_Violation,1) < cd
        
        % If more than one active dataset is used, additional 1st dimension
        % preallocation is performed (size(...,1))
        d.Result.Grid.(cg).Voltage_Violation(cd,:,:) = zeros(1,...
            handles.Current_Settings.Simulation.Timepoints,...
            numel(d.Grid.All_Node.Points));        
    end

    % Update voltages at all nodes for unsymmetrical loadflow
    d.Grid.All_Node.Points.update_voltage_node_LF_USYM;
    node_voltages = vertcat(d.Grid.All_Node.Points.Voltage);
    
    % d.Grid.All_Node.Points.define_voltage_limits;
        % This can be accessed during on-line calculations or at the
        % network_load start. If voltage limits will be changed during the
        % calculation phase, it is sensible to recheck the values, otherwise we
        % can only check the voltage limits once.  
     node_rated_voltages = vertcat(d.Grid.All_Node.Points.Rated_Voltage_phase_earth);
     
     node_voltages_pu = node_voltages ./ node_rated_voltages;
     % Voltage_violation_check - 
        % True/False array where the condition u > umax | u < umin is checked
     % Voltage_violation_check_2 - 
        % check_2 - True/False array where the condition u > umax2 | u < umin is checked
         
     voltage_limit_values_pu = vertcat(d.Grid.All_Node.Points.Voltage_Limits)/100;
      % voltage_limits defined as 4 element matrix
                % [upper_U_limit  lower_U_limit  upper_U_limit2   lower_U_limit2]


     if d.Simulation.Voltage_Violation_limits == 0 
         if size(voltage_limit_values_pu,1) == sum(voltage_limit_values_pu(:,1) == voltage_limit_values_pu(:,3)) & ...
            size(voltage_limit_values_pu,1) == sum(voltage_limit_values_pu(:,2) == voltage_limit_values_pu(:,4))    
             % Determine if only one voltage limit is set across all nodes (more common than two)
             % If all uul = uul2 and ull = ull2 are the same, comparison truth values
             % equal the number of all nodes!
             d.Simulation.Voltage_Violation_limits = 1;
             % Only one limit is defined ... d.Simulation.Voltage_Violation_limits = 1;
         else
             d.Simulation.Voltage_Violation_limits = 2;
             % Two limits are defined ... d.Simulation.Voltage_Violation_limits = 2;
         end
     end
     
     voltage_violation_check  = node_voltages_pu > repmat(voltage_limit_values_pu(:,1),1,3) | ...  % upper voltage limit
                                node_voltages_pu < repmat(voltage_limit_values_pu(:,2),1,3);        % lower voltage limit
 

     if d.Simulation.Voltage_Violation_limits == 2
         voltage_violation_check2 = node_voltages_pu > repmat(voltage_limit_values_pu(:,3),1,3) | ...  % upper voltage limit
                                    node_voltages_pu < repmat(voltage_limit_values_pu(:,4),1,3);       % lower voltage limit

         d.Result.Grid.(cg).Voltage_Violation(cd,ct,:) = ...
             1*(sum(voltage_violation_check,2) > 0) +...
             1*(sum(voltage_violation_check2,2) > 0);         
     else
         d.Result.Grid.(cg).Voltage_Violation(cd,ct,:) = ...
             1*(sum(voltage_violation_check,2) > 0);
         % d.Result.Grid.Grid_act.Voltage_Violation(cd,ct) is a 1xnode array
         % with values 0 (no voltage limits exceeded), 1 (first voltage limit
         % exceeded) and 2 (both voltage limits exceeded)!         
     end
     
%      d.Result.Grid.(cg).Voltages(cd,ct,:,:) = 
     
     
   
end
        
     

        


% also the Tables of the SINCAL-Object are accessable to write own
% functions:
% % % handles.sin.Tables.Element;
% as well as all other object of the SINCAL-automatization.


% The Results are stored in the structure "Grid" within the "Result"-Structure:
% % % d.Result.Grid.Grid_act = [];
% I would propose an array like this
% % % d.Result.Grid.(cg)(cd,ct,:,:) = load_node_voltages;% = "payload"
% The payload is also as a 2D-Array, where the rows are mapped to the
% elements, which are investigated (e.g. branches), the columns are the data of
% interest (e.g. rating of overcurrent).
end

