classdef Post_Power_Loss_Analysis < handle
    
    % Version:                 1.1
    % Erstellt von:            Matej Rejc      - 17.04.2013
    % Letzte �nderung durch:
    properties  
            % Summary report of active power losses at specific voltage
            % levels and the last column includes the sum of all voltage
            % levels  
        Max_Power_Loss_Values = [];
        Min_Power_Loss_Values = [];
        Std_Power_Loss_Values = [];
    end
                
    properties(GetAccess = 'private')        
        Grid_Name = [];
            % Name of grid, used for displaying information  
        Timepoints = [];
            % Number of observations, set to private for clearer class display    
        Voltage_Level_ID = [];
            % branch_voltage_level_id is the list of all voltage level ids,
            % i.e. 1st, 2nd, ..., i-th, ...n-th voltage level id
        Voltage_Level_Val = [];
            % branch_voltage_level_val is the list of rated voltage levels
            % for the i-th voltage level id
        Branches_at_Voltage_Levels =[];
           % branch_at_voltage_level{i} is a cell array where numerical
           % values of branches that belong to the i-th voltage level are            
    end
    
    methods
        function obj = Post_Power_Loss_Analysis(ext_obj,ext_grid,grid_name)            
            % Private properties of class defined
            obj.Grid_Name = grid_name;            
            timepoints = size(ext_obj.Power_Loss_Analysis,2);
            obj.Timepoints = timepoints;            
            obj.Voltage_Level_ID = ext_grid.Branches.grouped_voltage_level_id;            
            obj.Voltage_Level_Val = ext_grid.Branches.grouped_voltage_level_val;            
            obj.Branches_at_Voltage_Levels = ext_grid.Branches.grouped_branches_at_voltage_level;
            
            % Post processing of active power losses
            for cd = 1 : size(ext_obj.Power_Loss_Analysis,1) % Datasets
                obj.Max_Power_Loss_Values(cd,:) = max(squeeze(ext_obj.Power_Loss_Analysis(cd,:,:)));
                obj.Min_Power_Loss_Values(cd,:) = min(squeeze(ext_obj.Power_Loss_Analysis(cd,:,:)));
                obj.Std_Power_Loss_Values(cd,:) = std(squeeze(ext_obj.Power_Loss_Analysis(cd,:,:)));
                % Last column of max_, min_ and std_ variables is the entire
                % grid value
            end
        end % Power_Loss_Summary(ext_obj,cg)
        
        function obj = Display_results(obj)
            fprintf('\n------------------------------------------------------------------------------------\n');
            fprintf('Summary of active power loss analysis\n');
            fprintf(['Grid name        >> ' obj.Grid_Name '\n']);
            fprintf('------------------------------------------------------------------------------------\n');
            
            for i = 1 : size(obj.Max_Power_Loss_Values,1)
                fprintf(['Dataset observed >> ' int2str(i) ' / '...
                    int2str(size(obj.Max_Power_Loss_Values,1)) '\n\n' ]);
                
                % The prefix of the power losses - kW or MW
                if size(int2str(round(obj.Max_Power_Loss_Values(i,end))),2) > 6
                    % If the number is larger than 0.1e6
                    prefix = 1e6; text_prefix = 'M';
                else
                    % The number is in the 1e3 range
                    prefix = 1e3; text_prefix = 'k';
                end
                
                
                fprintf(['Highest / Lowest total network loss is '...
                         num2str(obj.Max_Power_Loss_Values(i,end)/prefix)...
                         ' ' text_prefix 'W / '...
                         num2str(obj.Min_Power_Loss_Values(i,end)/prefix)...
                          ' ' text_prefix 'W \n']);
                      
                fprintf(['Standard deviation of total network losses is '...
                         num2str(obj.Std_Power_Loss_Values(i,end)/prefix)...
                         ' ' text_prefix 'W \n\n']);                     
            end % For            
        end % Display_results function
        
        
    end % Methods

end % Classdef