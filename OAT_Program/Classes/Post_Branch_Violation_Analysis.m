classdef Post_Branch_Violation_Analysis < handle
    
    % Version:                 1.2
    % Erstellt von:            Matej Rejc      - 17.04.2013
	% Letzte Änderung durch:   Matej Rejc      - 29.04.2013
    properties

        Number_of_Violations = [];
            % Number of times branch violations occured at base, 1st, 2nd
            % or 3rd additional thermal limit
        Number_of_Violations_percent = [];
            % Percentage of times branch violations occured at base, 1st, 2nd
            % or 3rd limit        
        Number_of_Branches_With_Violations = [];
            % Number of branches, where branch violations occured at base, 1st, 2nd
            % or 3rd limit
        Number_of_Branches_With_Violations_percent = [];
            % Percentage of branches, where branch violations occured at base, 1st, 2nd
            % or 3rd limit
        Names_of_Branches_With_Violations = [];
            % Names of branches, where branch violations occured at base, 1st, 2nd
            % or 3rd limit
        Branch_Names = []; 
            % Branch names   
           
    end
    
    properties(GetAccess = 'private')        
        Grid_Name = [];
            % Name of grid, used for displaying information  
        Timepoints = [];
            % Number of observations, set to private for clearer class display    
        Branch_Type = []; 
    end
    
    methods
        function obj = Post_Branch_Violation_Analysis(ext_obj,ext_grid,grid_name)

            % Object_information displays information about the object
            % Additional information can be added later and the value set
            % to public
            
                % We can observe lines or transformers. We define
                % observed_branch_violation and observed_grid_branch to access
                % either lines or transformers
                observed_branch_violation = ext_obj.Branch_Violation_Analysis;
                observed_grid_branch = ext_grid.Branches.Grouped;
                
                % What is the Grid name - private property for displaying
                % results
                obj.Grid_Name = grid_name;
                
                % All branches (lines/transformers) in grid
                branch_names = cell(1,numel(observed_grid_branch));
                for k = 1 : numel(observed_grid_branch)
                    branch_names{k} = observed_grid_branch(k).Branch_Name;
                end
                obj.Branch_Names = branch_names;
                
                % Number of timepoints analysed
                obj.Branch_Type = vertcat(ext_grid.Branches.Grouped.Branch_Type_ID);
                % Lines are represented by the numerical value 1, 2w
                % transformers by numerical value 2
                
                timepoints = size(observed_branch_violation,2);
                obj.Timepoints = timepoints;
                
                for cd = 1 : size(observed_branch_violation,1)
                    % Iterate through all datasets cd = size(results,1)
                    
                    % The squeezed values for dataset cd and topology (cg) are saved in
                    % branch_violation_results
                    branch_violation_results(:,1:numel(observed_grid_branch)) =...
                        squeeze( observed_branch_violation(cd,:,:) );
                    
                    % Branch violations (base...1, 1st...2, 2nd...3, 3rd..4)
                    branch_violation1_at_timepoints = sum(branch_violation_results == 1,2) > 0;
                    branch_violation2_at_timepoints = sum(branch_violation_results == 2,2) > 0;
                    branch_violation3_at_timepoints = sum(branch_violation_results == 3,2) > 0;
                    branch_violation4_at_timepoints = sum(branch_violation_results == 4,2) > 0;
                    
                    
                    % Number of times the grid experienced current violations
                    grid_experienced_branch_violations(1) = sum(branch_violation1_at_timepoints);
                    grid_experienced_branch_violations(2) = sum(branch_violation2_at_timepoints);
                    grid_experienced_branch_violations(3) = sum(branch_violation3_at_timepoints);
                    grid_experienced_branch_violations(4) = sum(branch_violation4_at_timepoints);
                    
                    
                    % Define the names of branches with violations
                    % First define the ids (true/false) of branches where limits are violated
                    violations1_at_branches_ids = sum(branch_violation_results == 1,1) > 0;
                    violations2_at_branches_ids = sum(branch_violation_results == 2,1) > 0;
                    violations3_at_branches_ids = sum(branch_violation_results == 3,1) > 0;
                    violations4_at_branches_ids = sum(branch_violation_results == 4,1) > 0;
                    
                    % Number of branches, where specific limit violations
                    % occur [1st limit, 2nd limit, 3rd, 4th]
                    number_of_branches_with_violations(1) = sum(violations1_at_branches_ids);
                    number_of_branches_with_violations(2) = sum(violations2_at_branches_ids);
                    number_of_branches_with_violations(3) = sum(violations3_at_branches_ids);
                    number_of_branches_with_violations(4) = sum(violations4_at_branches_ids);
                    
                    obj.Number_of_Violations(cd,:) = grid_experienced_branch_violations;
                    obj.Number_of_Violations_percent(cd,:) = 100* grid_experienced_branch_violations / timepoints;
                    
                    obj.Number_of_Branches_With_Violations(cd,:) = number_of_branches_with_violations;
                    
                    obj.Number_of_Branches_With_Violations_percent(cd,:) = ...
                        100 * number_of_branches_with_violations / size(observed_branch_violation,3);
                    
                    obj.Names_of_Branches_With_Violations{cd,1} = branch_names(violations1_at_branches_ids);
                    obj.Names_of_Branches_With_Violations{cd,2} = branch_names(violations2_at_branches_ids);
                    obj.Names_of_Branches_With_Violations{cd,3} = branch_names(violations3_at_branches_ids);
                    obj.Names_of_Branches_With_Violations{cd,4} = branch_names(violations4_at_branches_ids);
                    
                end
        end % End of main function
            
        function obj = Display_results(obj)            
            fprintf(['------------------------------------------------------------------------------\n']);
            for i = 1 : size(obj.Number_of_Violations,1)
                fprintf(['Branch violations;' obj.Grid_Name ';']);
                if sum(obj.Number_of_Violations) == 0
                    %if no branch violations exist
                    fprintf(['Set ' int2str(i) '; No branch violations;\n']);
                else                    
                    if obj.Number_of_Violations(i,4) ~= 0
                        % Third additional limit exists
                        fprintf(['Set ' int2str(i) ';violations at '...
                            num2str(round(100*obj.Number_of_Branches_With_Violations_percent(i,1))/100),'/',... 
                            num2str(round(100*obj.Number_of_Branches_With_Violations_percent(i,2))/100),'/',...
                            num2str(round(100*obj.Number_of_Branches_With_Violations_percent(i,3))/100),'/',...
                            num2str(round(100*obj.Number_of_Branches_With_Violations_percent(i,4))/100),...                           
                            '%% branches at '...
                            num2str(round(100*obj.Number_of_Violations_percent(i,1))/100),'/'...
                            num2str(round(100*obj.Number_of_Violations_percent(i,2))/100),'/'...
                            num2str(round(100*obj.Number_of_Violations_percent(i,3))/100),'/'...
                            num2str(round(100*obj.Number_of_Violations_percent(i,4))/100),...
                            '%% timepoints; \n']);

                    elseif obj.Number_of_Violations(i,4) == 0 && obj.Number_of_Violations(i,3) ~= 0                        
                        fprintf(['Set ' int2str(i) ';violations at '...
                            num2str(round(100*obj.Number_of_Branches_With_Violations_percent(i,1))/100),'/',... 
                            num2str(round(100*obj.Number_of_Branches_With_Violations_percent(i,2))/100),'/',...
                            num2str(round(100*obj.Number_of_Branches_With_Violations_percent(i,3))/100),...                           
                            '%% branches at '...
                            num2str(round(100*obj.Number_of_Violations_percent(i,1))/100),'/'...
                            num2str(round(100*obj.Number_of_Violations_percent(i,2))/100),'/'...
                            num2str(round(100*obj.Number_of_Violations_percent(i,3))/100),...
                            '%% timepoints; \n']);
                        
                    elseif obj.Number_of_Violations(i,4) == 0 && obj.Number_of_Violations(i,3) == 0  &&...
                           obj.Number_of_Violations(i,2) ~= 0
                        fprintf(['Set ' int2str(i) ';violations at '...
                            num2str(round(100*obj.Number_of_Branches_With_Violations_percent(i,1))/100),'/',... 
                            num2str(round(100*obj.Number_of_Branches_With_Violations_percent(i,2))/100),...                           
                            '%% branches at '...
                            num2str(round(100*obj.Number_of_Violations_percent(i,1))/100),'/'...
                            num2str(round(100*obj.Number_of_Violations_percent(i,2))/100),...
                            '%% timepoints; \n']);
                        
                    elseif obj.Number_of_Violations(i,4) == 0 && obj.Number_of_Violations(i,3) == 0  &&...
                           obj.Number_of_Violations(i,2) == 0 && obj.Number_of_Violations(i,1) ~= 0
                        fprintf(['Set ' int2str(i) ';violations at '...
                            num2str(round(100*obj.Number_of_Branches_With_Violations_percent(i,1))/100),...                           
                            '%% branches at '...
                            num2str(round(100*obj.Number_of_Violations_percent(i,1))/100),...
                            '%% timepoints; \n']);                        
                    end
                end 
            end % For
        end         
end % Methods

end % Classdef