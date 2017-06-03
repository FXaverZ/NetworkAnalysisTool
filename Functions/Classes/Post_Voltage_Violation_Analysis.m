classdef Post_Voltage_Violation_Analysis < handle
    
    % Version:                 1.1
    % Erstellt von:            Matej Rejc      - 17.04.2013
    % Letzte Änderung durch:
    properties

        Number_of_Violations = [];
            % Number of times voltage violations occured at 1st limit, 2nd
            % limit and either of the two limits [1st limit, 2nd limit, 1st+2nd]
        Number_of_Violations_percent = [];
            % Percentage of  voltage violations occured at 1st limit, 2nd
            % limit and either of the two limits [1st limit, 2nd limit, 1st+2nd]
        Number_of_Nodes_With_Violations = [];
            % Number of nodes, where voltage violations occured at 1st limit, 2nd
            % limit and either of the two limits [1st limit, 2nd limit, 1st+2nd]
        Number_of_Nodes_With_Violations_percent = [];
            % Percentage of nodes, where voltage violations occured at 1st limit, 2nd
            % limit and either of the two limits [1st limit, 2nd limit, 1st+2nd]
        Names_of_Nodes_With_Violations = [];
            % Names of nodes, where voltage violations occured at 1st limit, 2nd
            % limit and either of the two limits [1st limit, 2nd limit, 1st+2nd]
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
                
                % Voltage violations (A...both limits, 1...first, 2...second voltage limit)
                voltage_violationsA_at_timepoints = sum(voltage_violation_results ~= 0,2) > 0;
                voltage_violations1_at_timepoints = sum(voltage_violation_results == 1,2) > 0;
                voltage_violations2_at_timepoints = sum(voltage_violation_results == 2,2) > 0;
                
                % Number of times the grid experienced voltage violations
                % grid_experienced_voltage_violations [1st, 2nd, 1st+2nd]
                grid_experienced_voltage_violations(1) = sum(voltage_violations1_at_timepoints);
                grid_experienced_voltage_violations(2) = sum(voltage_violations2_at_timepoints);
                grid_experienced_voltage_violations(3) = sum(voltage_violationsA_at_timepoints);
                
               
                
                % Define the names of nodes with voltage limit violations
                % First define the ids (true/false) of nodes where voltages
                % are violated
                voltage_violationsA_at_nodes_ids = sum(voltage_violation_results ~= 0,1) > 0;
                voltage_violations1_at_nodes_ids = sum(voltage_violation_results == 1,1) > 0;
                voltage_violations2_at_nodes_ids = sum(voltage_violation_results == 2,1) > 0;
                
                % Number of nodes, where specific voltage violations
                % occur [1st limit, 2nd limit, 1st+2nd limit]
                number_of_nodes_with_voltage_violations(1) = sum(voltage_violations1_at_nodes_ids);
                number_of_nodes_with_voltage_violations(2) = sum(voltage_violations2_at_nodes_ids);
                number_of_nodes_with_voltage_violations(3) = sum(voltage_violationsA_at_nodes_ids);
                
                                
                obj.Number_of_Violations(cd,:) = grid_experienced_voltage_violations;
                obj.Number_of_Violations_percent(cd,:) = 100* grid_experienced_voltage_violations / timepoints;
                
                obj.Number_of_Nodes_With_Violations(cd,:) = number_of_nodes_with_voltage_violations;
                
                obj.Number_of_Nodes_With_Violations_percent(cd,:) = ...
                    100 * number_of_nodes_with_voltage_violations / size(ext_obj.Voltage_Violation_Analysis,3);
            
                obj.Names_of_Nodes_With_Violations{cd,1} = node_names(voltage_violations1_at_nodes_ids);
                obj.Names_of_Nodes_With_Violations{cd,2} = node_names(voltage_violations2_at_nodes_ids);
                obj.Names_of_Nodes_With_Violations{cd,3} = node_names(voltage_violationsA_at_nodes_ids);
                
            
            end
        end % function Post_Voltage_Analysis
        
        function obj = Display_results(obj)
            fprintf('\n------------------------------------------------------------------------------------\n');
            fprintf('Summary of voltage violation analysis\n');
            fprintf(['Grid name        >> ' obj.Grid_Name '\n']);
            fprintf('------------------------------------------------------------------------------------\n');

            for i = 1 : size(obj.Number_of_Violations,1)
                fprintf(['Dataset observed >> ' int2str(i) ' / '...
                         int2str(size(obj.Number_of_Violations,1)) '\n\n' ]);                        
                     
                if sum(obj.Number_of_Violations) == 0                    
                    % If no voltage violations exist
                    fprintf('No voltage violations!\n');
                    
                elseif obj.Number_of_Violations(i,1) == obj.Number_of_Violations(i,3) &&...
                        sum(obj.Number_of_Violations(i,:)) ~= 0  % If no second limit exists but voltage violations occur
                    
                    fprintf(['Voltage violations at Uul and Ull occured at ' int2str(obj.Number_of_Violations(i,1))...
                        ' of ' int2str(obj.Timepoints) ' observed timepoints ('...
                        num2str(round(100*obj.Number_of_Violations_percent(i,1))/100) ' %%) \n\n']);
                    
                    fprintf(['Voltage violations at Uul and Ull occured at ' int2str(obj.Number_of_Nodes_With_Violations(i,1))...
                        ' nodes out of ' int2str(numel(obj.All_Node_Names)) ' ('...
                        num2str(round(100*obj.Number_of_Nodes_With_Violations_percent(i,1))/100) ' %%) \n']);
                    
                else
                    fprintf(['Voltage violations at Uul and Ull occured at ' int2str(obj.Number_of_Violations(i,1))...
                        ' of ' int2str(obj.Timepoints) ' observed timepoints ('...
                        num2str(round(100*obj.Number_of_Violations_percent(i,1))/100) ' %%) \n']);
                    
                    fprintf(['Voltage violations at Uul1 and Ull1 occured at ' int2str(obj.Number_of_Violations(i,2))...
                        ' of ' int2str(obj.Timepoints) ' observed timepoints ('...
                        num2str(round(100*obj.Number_of_Violations_percent(i,2))/100) ' %%) \n']);
                    
                    fprintf(['Voltage violations at either limits occured at ' int2str(obj.Number_of_Violations(i,3))...
                        ' of ' int2str(obj.Timepoints) ' observed timepoints ('...
                        num2str(round(100*obj.Number_of_Violations_percent(i,3))/100) ' %%) \n\n']);
                    
                    fprintf(['Voltage violations at Uul and Ull occured at '...
                        int2str(obj.Number_of_Nodes_With_Violations(i,1))...
                        ' nodes out of ' int2str(numel(obj.All_Node_Names)) ' ('...
                        num2str(round(100*obj.Number_of_Nodes_With_Violations_percent(i,1))/100) ' %%) \n']);
                    
                    fprintf(['Voltage violations at Uul1 and Ull1 occured at '...
                        int2str(obj.Number_of_Nodes_With_Violations(i,2))...
                        ' nodes out of ' int2str(numel(obj.All_Node_Names)) ' ('...
                        num2str(round(100*obj.Number_of_Nodes_With_Violations_percent(i,2))/100) ' %%) \n']);
                    
                    fprintf(['Voltage violations at either limit occured at '...
                        int2str(obj.Number_of_Nodes_With_Violations(i,3))...
                        ' nodes out of ' int2str(numel(obj.All_Node_Names)) ' ('...
                        num2str(round(100*obj.Number_of_Nodes_With_Violations_percent(i,3))/100) ' %%) \n']);
                    
                   
                end

            end

        end
        
    end % Methods

end % Classdef