function handles = online_branch_violation_analysis(handles)
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

%-------------------------------------------------------------------
% Thermal limits can be recheck on-line if they change during
% simulation
% d.Grid.(cg).Branches.Lines.define_branch_limits;  % <----------
% d.Grid.(cg).Branches.Transf.define_branch_limits; % <----------

% Line limits are in most cases given in A, therefore we will check
% limit values by comparing I to Ilim
% d.Simulation.Branch_Violation_analysis.line_current_limits = ...
%     vertcat(d.Grid.(cg).Branches.Lines.Current_Limits); % <----------

% Transf. limits are in most cases given in VA, therefore we will check
% limit values by comparing S to Smax
% d.Simulation.Branch_Violation_analysis.transf_app_power_limits = ...
%     vertcat(d.Grid.(cg).Branches.Transf.App_Power_Limits); % <----------

% Merge line and transformer limits
% d.Simulation.Branch_Violation_analysis.branch_limits = ...
%     [d.Simulation.Branch_Violation_analysis.line_current_limits;...
%      d.Simulation.Branch_Violation_analysis.transf_app_power_limits];  % <----------

%-------------------------------------------------------------------
% Online branch element violation analysis for unsymetric load flow
%-------------------------------------------------------------------

% Check line currents
d.Grid.(cg).Branches.Lines.update_current_branch_LF_USYM;
line_currents = vertcat(d.Grid.(cg).Branches.Lines.Current);

% Check transformer apparent power flow
d.Grid.(cg).Branches.Transf.update_power_branch_LF_USYM;
transf_apparent_power = vertcat(d.Grid.(cg).Branches.Transf.Apparent_Power);


if ~isempty(line_currents)     
     % branch_violation_check for lines with 1st thermal limit defined
     % "line_current_limits(:,1)"
     branch_violation_check_lines  = ...
         1*( max(line_currents(:,1:3),[],2) >...
         d.Simulation.Branch_Violation_analysis.line_current_limits(:,1));      
     % Checks the maximum current in the three phases, if any phase is
     % overloaded, branch violation occurs! 
else
    branch_violation_check_lines = [];
end

if ~isempty(transf_apparent_power)   
    % Branch violation check for transformers
    % Reminder: Current limits are single phase values, while apparent
     % power limits are threephase equiv. values! Important for transf.
     % checking, since that uses apparent power! Use first rated thermal
     % "transf_app_power_limits(:,1)"
     % power (
     branch_violation_check_transf  = ...
        1*( sum(transf_apparent_power(:,1:3),2) >...
        d.Simulation.Branch_Violation_analysis.transf_app_power_limits(:,1));     
else
    branch_violation_check_transf = [];
end

% Group the branch violation checks!
branch_violation_check_group = ...
    [branch_violation_check_lines;branch_violation_check_transf ];
     
% Write the results into the d.Result.(cg).Branch_Violation_Analysis
     
 d.Result.(cg).Branch_Violation_Analysis(cd,ct,:) = ...
     branch_violation_check_group;  % Lines + Transformers!
 

end

