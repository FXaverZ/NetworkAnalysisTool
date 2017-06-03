classdef Post_Voltage_Violation_Analysis < handle
    
    % Version:                 1.2
    % Erstellt von:            Matej Rejc      - 17.04.2013
    % Letzte Änderung durch:   Matej Rejc      - 24.04.2013
	
    properties

        Number_of_Violations = [];
            % Number of times voltage violations occured at base limit
        Number_of_Violations_percent = [];
            % Percentage of  voltage violations occured at base limit
        Number_of_Nodes_With_Violations = [];
            % Number of nodes, where voltage violations occured at base limit
        Number_of_Nodes_With_Violations_percent = [];
            % Percentage of nodes, where voltage violations occured at base limit
        Names_of_Nodes_With_Violations = [];
            % Names of nodes, where voltage violations occured at base limit
        All_Node_Names = []; 
            % Node names, set to private for clearer class display  
    end
    
    properties(GetAccess = 'private')        
        Grid_Name = [];
            % Name of grid, used for displaying information
        Timepoints = [];
            % Number of observations, set to private for clearer class display  
        Voltage_Limits = [];
    end
    
    
    methods
        function obj = Post_Voltage_Violation_Analysis(ext_obj,ext_grid,grid_name)
            % Names of nodes in grid
            node_names = cell(1,numel(ext_grid.All_Node.Points));
            for k = 1 : numel(ext_grid.All_Node.Points)
                node_names{k} = ext_grid.All_Node.Points(k).Node_Name;
            end
            obj.All_Node_Names = node_names;
            obj.Grid_Name = grid_name;
            
            % Voltage limits
            obj.Voltage_Limits = vertcat(ext_grid.All_Node.Points.Voltage_Limits);
            
             % Number of timepoints analysed
            timepoints = size(ext_obj.Voltage_Violation_Analysis,2);
            obj.Timepoints = timepoints;
            
            for cd = 1 : size(ext_obj.Voltage_Violation_Analysis,1)
                % Iterate through all datasets cd = size(results,1)
                
                % The squeezed values for dataset cd and topology (cg) are saved in
                % voltage_violation_results
                voltage_violation_results =...
                    squeeze( ext_obj.Voltage_Violation_Analysis(cd,:,:) );
                
                % Voltage violations 
                voltage_violations_at_timepoints = sum(voltage_violation_results == 1 & ~isnan(voltage_violation_results),2) > 0;
                
                % Number of times the grid experienced voltage violations
                grid_experienced_voltage_violations(1) = sum(voltage_violations_at_timepoints);
                               
                % Define the names of nodes with voltage limit violations
                % First define the ids (true/false) of nodes where voltages
                % are violated
                voltage_violations_at_nodes_ids = sum(voltage_violation_results == 1 & ~isnan(voltage_violation_results),1) > 0;
                
                % Number of nodes, where specific voltage violations
                % occur [1st limit, 2nd limit, 1st+2nd limit]
                number_of_nodes_with_voltage_violations(1) = sum(voltage_violations_at_nodes_ids);
                       
                                
                obj.Number_of_Violations(cd,:) = grid_experienced_voltage_violations;
                obj.Number_of_Violations_percent(cd,:) = 100* grid_experienced_voltage_violations / timepoints;
                
                obj.Number_of_Nodes_With_Violations(cd,:) = number_of_nodes_with_voltage_violations;
                
                obj.Number_of_Nodes_With_Violations_percent(cd,:) = ...
                    100 * number_of_nodes_with_voltage_violations / size(ext_obj.Voltage_Violation_Analysis,3);
            
                obj.Names_of_Nodes_With_Violations{cd,1} = node_names(voltage_violations_at_nodes_ids);
                            
            end
        end % function Post_Voltage_Analysis
        function obj = Display_results(obj)
            fprintf(['------------------------------------------------------------------------------\n']);
            for i = 1 : size(obj.Number_of_Violations,1)
                fprintf(['Voltage violations;' obj.Grid_Name ';']);   
                if obj.Number_of_Violations(i,1) == 0
                    %if no branch violations exist
                    fprintf(['Set ' int2str(i) ';no voltage violations;\n']);
                else
                    fprintf(['Set ' int2str(i) ';violations at '...
                        num2str(round(100*obj.Number_of_Nodes_With_Violations_percent(i,1))/100),...
                        ' %% nodes at '...
                        num2str(round(100*obj.Number_of_Violations_percent(i,1))/100),...
                        ' %% timepoints; \n']);                 
                end
            end
        end
    end % Methods

end % Classdef