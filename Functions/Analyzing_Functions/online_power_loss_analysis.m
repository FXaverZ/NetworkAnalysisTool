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
% Online active power loss analysis for unsymetric load flow
%-------------------------------------------------------------------

% Check line currents
d.Grid.(cg).Branches.Lines.update_power_branch_LF_USYM_from;

line_active_power = vertcat(d.Grid.(cg).Branches.Lines.Current);

% Check transformer apparent power flow
d.Grid.(cg).Branches.Transf.update_power_branch_LF_USYM_from;
transf_apparent_power = vertcat(d.Grid.(cg).Branches.Transf.Apparent_Power);


if ~isempty(line_currents)     
     % branch_violation_check for lines
     branch_violation_check_lines  = ...
         1*( repmat(max(line_currents(:,1:3),[],2),1,...
         size(d.Simulation.Branch_Violation_analysis.line_current_limits,2)) >...
         d.Simulation.Branch_Violation_analysis.line_current_limits);      
     % Checks the maximum current in the three phases, if any phase is
     % overloaded, branch violation occurs! All limits are compared simultaneously 
     % in a n x 4 matrix. Additionally separate lines and transformers

     % Add weights for different thermal limits - this is needed for result
     % analysis (so the user knows which limit is reached)
     branch_violation_check_lines(:,1) = 1*branch_violation_check_lines(:,1);
     branch_violation_check_lines(:,2) = 2*branch_violation_check_lines(:,2);
     branch_violation_check_lines(:,3) = 3*branch_violation_check_lines(:,3);
     branch_violation_check_lines(:,4) = 4*branch_violation_check_lines(:,4);

else
    branch_violation_check_lines = [];
end

if ~isempty(transf_apparent_power)   
    % Branch violation check for transformers
    % Reminder: Current limits are single phase values, while apparent
     % power limits are threephase equiv. values! Important for transf.
     % checking, since that uses apparent power!
     branch_violation_check_transf  = ...
        1*( repmat(sum(transf_apparent_power(:,1:3),2),1,...
        size(d.Simulation.Branch_Violation_analysis.transf_app_power_limits,2)) >...
        d.Simulation.Branch_Violation_analysis.transf_app_power_limits);  
    % Add weights for different thermal limits - this is needed for result
    % analysis (so the user knows which limit is reached)    
    branch_violation_check_transf(:,1) = 1*branch_violation_check_transf(:,1);
    branch_violation_check_transf(:,2) = 2*branch_violation_check_transf(:,2);
    branch_violation_check_transf(:,3) = 3*branch_violation_check_transf(:,3);
    branch_violation_check_transf(:,4) = 4*branch_violation_check_transf(:,4);
else
    branch_violation_check_transf = [];
end

% Group the branch violation checks!
branch_violation_check_group = ...
    [branch_violation_check_lines;branch_violation_check_transf ];
     
% Write the results into the d.Result.(cg).Branch_Violation_Analysis
     % If multiple limits are defined, the results will not give values
     % of 1 (base limit exceeded), but 1,2,3,4 (base = 1, base+1st
     % limit =2, base+1st + 2nd limit = 3, base + 1st+ 2nd + 3rd limit = 4)
     
 d.Result.(cg).Branch_Violation_Analysis(cd,ct,:) = ...
     max(branch_violation_check_group,[],2);  % Lines + Transformers!
 

end

