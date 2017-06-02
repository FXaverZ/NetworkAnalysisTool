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

%---- temporary (to define later)
save_branch_values = 1; % save branch values in SI units
% save_branch_values = 0; % do not save the branch values
%---------


% Branch_limit_violation_analysis value is used for preallocating the
% on-line result array
if ~isfield(d.Simulation, 'Branch_limit_Violation_analysis')
	d.Simulation.Branch_limit_Violation_analysis = 0;   
    % Branch_limit_violation_analysis value is used for preallocating the
    % on-line result array
        % 0 ... no branch limit violation analysis yet performed,
        % first preallocation for first active dataset
end

if ~isfield(d.Simulation, 'Branch_Violation_limits')
    d.Simulation.Branch_Violation_limits = 0;
    % Branch_limit_Violation_analysis value is used to determine whether
    % more than the basic thermal limit for an element is defined across
    % all branches
        % 0 ... number of branch limits not determined yet
end
%-------------------------------------------------------------------        


% Check what type of simulation was performed and use appropriate functions
if strcmp(handles.Current_Settings.Simulation.Parameters(2),'LF_USYM') % Unsymetric load flow

    if d.Simulation.Branch_limit_Violation_analysis == 0  
        % d.Simulation.Branch_limit_Violation_analysis value is set to 1, i.e.
        % the first preallocation has been performed for the first active
        % dataset
        d.Simulation.Branch_limit_Violation_analysis = 1;   

        % If branch limit violation array does not exist yet for this topology
        % model and for this Input_Data_act, preallocation of the array is performed 
        
        % Seperate Lines and Transformers - COMMENT: should we keep them
        % separate?*************
        d.Result.Grid.(cg).Branch_limit_Violation.Lines(cd,...
            1:handles.Current_Settings.Simulation.Timepoints,...
            1:numel(d.Grid.Branches.Lines)) =...
                zeros(1,handles.Current_Settings.Simulation.Timepoints,...
                numel(d.Grid.Branches.Lines));
    
        % Transformer results given separately
        d.Result.Grid.(cg).Branch_limit_Violation.Transf(cd,...
            1:handles.Current_Settings.Simulation.Timepoints,...
            1:numel(d.Grid.Branches.Transf)) =...
                zeros(1,handles.Current_Settings.Simulation.Timepoints,...
                numel(d.Grid.Branches.Transf));          
        
        
        if save_branch_values > 0 
            % If branch P,Q,S,I values will be saved ,preallocation of arrays are
            % performed            
            % Seperate Lines and Transformers - COMMENT: should we keep them
            % separate?*************
            d.Result.Grid.(cg).Branches.Lines(cd,...
                1:handles.Current_Settings.Simulation.Timepoints,...
                1:numel(d.Grid.Branches.Lines),...
                1:16) = ...                
                    zeros(1,handles.Current_Settings.Simulation.Timepoints,...
                    numel(d.Grid.Branches.Lines),16);  
                
            % Array has the following format:
            % [P1 Q1 S1 I1 P2 Q2 S2 I2 P3 Q3 S3 I3 Pe Qe Se Ie] (4 values
            % per phase and phase-ground)            
            d.Result.Grid.(cg).Branches.Transf(cd,...
                1:handles.Current_Settings.Simulation.Timepoints,...
                1:numel(d.Grid.Branches.Transf),...
                :) = ...
                    zeros(1,handles.Current_Settings.Simulation.Timepoints,...
                    numel(d.Grid.Branches.Transf),16);  
            % Array has the following format:
            % [P1 Q1 S1 I1 P2 Q2 S2 I2 P3 Q3 S3 I3 Pe Qe Se Ie] (4 values
            % per phase and phase-ground)      
        end    
        
    elseif d.Simulation.Branch_limit_Violation_analysis == 1 
        % Two separate conditions due to the separation of Lines and 2w
        % transf.
        
        % Lines ---- new dataset preallocation (for multiple simulations):
        if size(d.Result.Grid.(cg).Branch_limit_Violation.Lines,1) < cd
            % If more than one active dataset is used, additional 1st dimension
            % preallocation is performed (size(...,1))
            d.Result.Grid.(cg).Branch_limit_Violation.Lines(cd,...
                1:handles.Current_Settings.Simulation.Timepoints,...
                1:numel(d.Grid.Branches.Lines)) =...
                    zeros(1,handles.Current_Settings.Simulation.Timepoints,...
                    numel(d.Grid.Branches.Lines));
          
            % This elseif condition is used so first dataset values are not 
            % overwritten at preallocation step

            if save_branch_values > 0 
                % If branch P,Q,S,I values will be saved preallocation of arrays are
                % performed
                d.Result.Grid.(cg).Branches.Lines(cd,...
                1:handles.Current_Settings.Simulation.Timepoints,...
                1:numel(d.Grid.Branches.Lines),...
                1:16) = ...                
                    zeros(1,handles.Current_Settings.Simulation.Timepoints,...
                    numel(d.Grid.Branches.Lines),16);  
                % [P1 Q1 S1 I1 P2 Q2 S2 I2 P3 Q3 S3 I3 Pe Qe Se Ie] (4 values
                % per phase and phase-ground)  
 
            end 
        end % Lines - new dataset active, preallocation
        
        % Transf ---- new dataset preallocation (for multiple simulations):
        if size(d.Result.Grid.(cg).Branch_limit_Violation.Transf,1) < cd
            % If more than one active dataset is used, additional 1st dimension
            % preallocation is performed (size(...,1))

            d.Result.Grid.(cg).Branch_limit_Violation.Transf(cd,...
                1:handles.Current_Settings.Simulation.Timepoints,...
                1:numel(d.Grid.Branches.Transf)) =...
                    zeros(1,handles.Current_Settings.Simulation.Timepoints,...
                    numel(d.Grid.Branches.Transf));   
            % This elseif condition is used so first dataset values are not 
            % overwritten at preallocation step

            if save_branch_values > 0 
                % If branch P,Q,S,I values will be saved preallocation of arrays are
                % performed
                 d.Result.Grid.(cg).Branches.Transf(cd,...
                 1:handles.Current_Settings.Simulation.Timepoints,...
                 1:numel(d.Grid.Branches.Transf),...
                 1:16) = ...
                    zeros(1,handles.Current_Settings.Simulation.Timepoints,...
                    numel(d.Grid.Branches.Transf),16);  
                % [P1 Q1 S1 I1 P2 Q2 S2 I2 P3 Q3 S3 I3 Pe Qe Se Ie] (4 values
                % per phase and phase-ground)  
            end 
        end % Transformer - new dataset active, preallocation
    end % Preallocation of result arrays
          
    
    % Currents updated/defined by update_current_branch_LF_USYM function of branch
    % class
    d.Grid.Branches.Lines.update_current_branch_LF_USYM;
    d.Grid.Branches.Transf.update_current_branch_LF_USYM;

    % P,Q,S updated/defined by update_power_branch_LF_USYM function of branch
    % class
    d.Grid.Branches.Lines.update_power_branch_LF_USYM;
    d.Grid.Branches.Transf.update_power_branch_LF_USYM;

    % Save calculated values in a sorted array - lines
    line_currents = vertcat(d.Grid.Branches.Lines.Current);
    line_active_power = vertcat(d.Grid.Branches.Lines.Active_Power);
    line_reactive_power = vertcat(d.Grid.Branches.Lines.Reactive_Power);
    line_apparent_power = vertcat(d.Grid.Branches.Lines.Apparent_Power);
    % Save calculated values in a sorted array - 2w transformers
    transf_currents = vertcat(d.Grid.Branches.Transf.Current);
    transf_active_power = vertcat(d.Grid.Branches.Transf.Active_Power);
    transf_reactive_power = vertcat(d.Grid.Branches.Transf.Reactive_Power);
    transf_apparent_power = vertcat(d.Grid.Branches.Transf.Apparent_Power);
    
    
    % d.Grid.Branches.Lines.define_branch_limits;  % <----------
    % d.Grid.Branches.Transf.define_branch_limits; % <----------
        % This can be accessed during on-line calculations or at the
        % network_load start. If branch limits will be changed during the
        % calculation phase, it is sensible to recheck the values, otherwise we
        % can only check the  limits once.  
        
    % Line limits are in most cases given in A, therefore we will check
    % limit values by comparing I to Ilim
    line_current_limits = vertcat(d.Grid.Branches.Lines.Current_Limits);
    
    % Transf. limits are in most cases given in VA, therefore we will check
    % limit values by comparing S to Smax
    transf_app_power_limits = vertcat(d.Grid.Branches.Transf.App_Power_Limits);
    
     % branch_violation_check - 
        % True/False array where the condition i > ilim (lines) is checked
        % or S > Smax (transf) is checked
        
     if d.Simulation.Branch_Violation_limits == 0 
         % If values will be changing online, additional condition should be defined to recheck this everytime
         
         if isempty(line_current_limits) == 0 && isempty(transf_app_power_limits) == 0
             if sum(sum(line_current_limits - ...        
                     repmat(line_current_limits(:,1),1,size(line_current_limits,2)))) == 0 && ...
                     sum(sum(transf_app_power_limits - ...        
                     repmat(transf_app_power_limits(:,1),1,size(transf_app_power_limits,2)))) == 0 
                 
                 % Comparison of base limit values to other limits. If they are
                 % the same, the difference between the base value and others
                 % should be zero, and the sum of all differences should be 0
                 
                 d.Simulation.Branch_Violation_limits = 1;
                 % Only one limit is defined ... d.Simulation.Branch_Violation_limits = 1;
             else
                 d.Simulation.Branch_Violation_limits = 2;
                 % More than one thermal limit is defined ... d.Simulation.Branch_Violation_limits = 2;
             end
             
         elseif isempty(line_current_limits) == 0 & isempty(transf_app_power_limits) == 1
             % if no transformers exist!
             if sum(sum(line_current_limits - ...        
                     repmat(line_current_limits(:,1),1,size(line_current_limits,2)))) == 0 
                 % Comparison of base limit values to other limits. If they are
                 % the same, the difference between the base value and others
                 % should be zero, and the sum of all differences should be 0
                 
                 d.Simulation.Branch_Violation_limits = 1;
                 % Only one limit is defined ... d.Simulation.Branch_Violation_limits = 1;
             else
                 d.Simulation.Branch_Violation_limits = 2;
                 % More than one thermal limit is defined ... d.Simulation.Branch_Violation_limits = 2;
             end
             
         elseif isempty(line_current_limits) == 1 & isempty(transf_app_power_limits) == 0
             % if no lines exist!
             if sum(sum(line_current_limits - ...        
                     repmat(line_current_limits(:,1),1,size(line_current_limits,2)))) == 0 
                 % Comparison of base limit values to other limits. If they are
                 % the same, the difference between the base value and others
                 % should be zero, and the sum of all differences should be 0
                 
                 d.Simulation.Branch_Violation_limits = 1;
                 % Only one limit is defined ... d.Simulation.Branch_Violation_limits = 1;
             else
                 d.Simulation.Branch_Violation_limits = 2;
                 % More than one thermal limit is defined ... d.Simulation.Branch_Violation_limits = 2;
             end
             
         end % if the system has lines/transf?
     end % if branch_violation_limit == 0?
     
    
     % Check branch limit violations --- branch_violation_check ---
     % True/False array where the condition i > ilim (lines) is checked
     % or S > Smax (transf) is checked. All limits are compared simultaneously 
     % in a n x 4 matrix        
        
     % Separate lines and transformers
     % Lines
     if isempty(line_currents) == 0 % if lines exist
         branch_violation_check_lines  = ...
             1*( repmat(max(line_currents(:,1:3),[],2),1,size(line_current_limits,2)) >...
             line_current_limits); 
         % Checks the maximum current in the three phases, if any phase is
         % overloaded, branch violation occurs!         
         
         % Add weights for different thermal limits - this is needed for result
         % analysis (so the user knows which limit is reached)
         branch_violation_check_lines(:,1) = 1*branch_violation_check_lines(:,1);
         branch_violation_check_lines(:,2) = 2*branch_violation_check_lines(:,2);
         branch_violation_check_lines(:,3) = 3*branch_violation_check_lines(:,3);
         branch_violation_check_lines(:,4) = 4*branch_violation_check_lines(:,4);
         
         % Reminder: Current limits are single phase values, while apparent
         % power limits are threephase equiv. values! Important for transf.
         % checking, since that uses apparent power!
     else
         branch_violation_check_lines = [];
     end

     % Transformers
     if isempty(transf_apparent_power) == 0 % if 2w transf exist
         branch_violation_check_transf  = ...
             1*( repmat(sum(transf_apparent_power(:,1:3),2),1,size(transf_app_power_limits,2)) >...
             transf_app_power_limits);  
         
         
         % Add weights for different thermal limits - this is needed for result
         % analysis (so the user knows which limit is reached)    
         branch_violation_check_transf(:,1) = 1*branch_violation_check_transf(:,1);
         branch_violation_check_transf(:,2) = 2*branch_violation_check_transf(:,2);
         branch_violation_check_transf(:,3) = 3*branch_violation_check_transf(:,3);
         branch_violation_check_transf(:,4) = 4*branch_violation_check_transf(:,4);
     else
         branch_violation_check_transf = [];
     end
          
     if d.Simulation.Branch_Violation_limits == 2
         % If multiple limits are defined, the results will not give values
         % of 1 (base limit exceeded), but 1,2,3,4 (base = 1, base+1st
         % limit =2, base+1st + 2nd limit = 3, base + 1st+ 2nd + 3rd limit = 4)
         if isempty(branch_violation_check_lines) == 0 % do lines exist?
            d.Result.Grid.(cg).Branch_limit_Violation.Lines(cd,ct,:) = ...
             max(branch_violation_check_lines,[],2);  % Lines 
         else
             d.Result.Grid.(cg).Branch_limit_Violation.Lines = [];  % Non-existant lines
         end
         
         if isempty(branch_violation_check_transf) == 0 % do transf exist?
             d.Result.Grid.(cg).Branch_limit_Violation.Transf(cd,ct,:) = ...
                 max(branch_violation_check_transf,[],2); % Transformers  
         else
             d.Result.Grid.(cg).Branch_limit_Violation.Transf = []; % Non-existant Transformers   
         end
     else % If only one limit is checked, only the first value can be compared
         
         if isempty(branch_violation_check_lines) == 0 % do lines exist?
             d.Result.Grid.(cg).Branch_limit_Violation.Lines(cd,ct,:) = ...
                 branch_violation_check_lines(:,1);      % Lines
         else
             d.Result.Grid.(cg).Branch_limit_Violation.Lines = [];  % Non-existant lines
         end
         
         if isempty(branch_violation_check_transf) == 0 % do transf exist?
             d.Result.Grid.(cg).Branch_limit_Violation.Transf(cd,ct,:) = ...
                 branch_violation_check_transf(:,1);     % Transformers
         else
             d.Result.Grid.(cg).Branch_limit_Violation.Transf = []; % Non-existant Transformers
         end
          
         % d.Result.Grid.Grid_act.Branch_limit_Violation.Lines(cd,ct) is a 1xnode array
         % with values 0 (no  limits exceeded), 1 (base  limit
         % exceeded), 2 (base + 1st), 3 (base + 1st + 2nd) and 4(base
         % +1st+2nd+3rd)
         
         % d.Result.Grid.Grid_act.Branch_limit_Violation.Transf(cd,ct) is a 1xnode array
         % with values 0 (no  limits exceeded), 1 (base  limit
         % exceeded), 2 (base + 1st), 3 (base + 1st + 2nd) and 4(base
         % +1st+2nd+3rd)         
     end
         

     if save_branch_values == 1
         if isempty(line_currents) == 0
             d.Result.Grid.(cg).Branches.Lines(cd,ct,:,:) = ...
                 [line_active_power(:,1),line_reactive_power(:,1), line_apparent_power(:,1), line_currents(:,1),...
                 line_active_power(:,2),line_reactive_power(:,2), line_apparent_power(:,2), line_currents(:,2),...
                 line_active_power(:,3),line_reactive_power(:,3), line_apparent_power(:,3), line_currents(:,3),...
                 line_active_power(:,4),line_reactive_power(:,4), line_apparent_power(:,4), line_currents(:,4)];
         else
            d.Result.Grid.(cg).Branches.Lines = []; 
         end
         
         if isempty(transf_apparent_power) == 0
             d.Result.Grid.(cg).Branches.Transf(cd,ct,:,:) = ...
                 [transf_active_power(:,1),transf_reactive_power(:,1), transf_apparent_power(:,1), transf_currents(:,1),...
                 transf_active_power(:,2),transf_reactive_power(:,2), transf_apparent_power(:,2), transf_currents(:,2),...
                 transf_active_power(:,3),transf_reactive_power(:,3), transf_apparent_power(:,3), transf_currents(:,3),...
                 transf_active_power(:,4),transf_reactive_power(:,4), transf_apparent_power(:,4), transf_currents(:,4)];
         else
            d.Result.Grid.(cg).Branches.Transf = []; 
         end
          
         % Values saved in W, VAr, VA and A
          % [P1 Q1 S1 I1 P2 Q2 S2 I2 P3 Q3 S3 I3 Pe Qe Se Ie] (4 values
            % per phase and phase-ground)
     end
     
elseif strcmp(handles.Current_Settings.Simulation.Parameters(2),'LF_NR') % Unsymetric load flow
     disp('Not defined for NR loadflow yet!')
    
end
     
     
end

