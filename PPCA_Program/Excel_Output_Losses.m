classdef Excel_Output_Losses < handle    
    % EXCEL_OUTPUT    Loss post processing  class
    % Version:                 1.0
    % Erstellt von:            Matej Rejc - 14.05.2013
    % Letzte Änderung durch:   Matej Rejc - 14.05.2013
    
    properties
        Sheet;
    end
    properties(GetAccess = 'private')
        S; % Scenario
        G; % Grid
        D; % Dataset
        B; % Branch
        Voltage_Levels; % Voltage levels
    end
    
    
    methods
        function obj = Excel_Output_Losses()
            % Clear values from class object
        end
        
        function compare_datasets(obj,ext_obj,input)
            
            % XLS_RESULTS > SUMMARY : A summary of voltage violations
            h.Row_IDs_for_Datasets = [];
            for cd = 1 : ext_obj.Datasets
                h.Row_IDs_for_Datasets{cd,1} = ['Set ' int2str(cd)];
            end
            h.Row_IDs_for_Datasets = [{'Dataset'};h.Row_IDs_for_Datasets];
            % Add column headers 1st row
            h.Column_IDs_for_Summary = cell(1,numel(obj.Voltage_Levels));
            h.Column_IDs_for_Summary{1,1} = 'Network active power losses at dataset (W)';
            h.Column_IDs_for_Summary(1,1:numel(obj.Voltage_Levels)) = obj.Voltage_Levels;

            xls_results.Summary = [h.Column_IDs_for_Summary;num2cell(input.Summary)];
            xls_results.Summary = [h.Row_IDs_for_Datasets, xls_results.Summary];
            
            % XLS_RESULTS.SHEET.SUMMARY (DATASET COMPARISON) Includes 
            % xls_results.Summary
            
            sheet1.max_column_size = size(xls_results.Summary,2);
            sheet1.max_row_size = size(xls_results.Summary,1);
            sheet1.table = cell(sheet1.max_row_size,sheet1.max_column_size);            
            
            % Merge tables together
            inpval = xls_results.Summary;
           
            if sheet1.max_column_size < 11
                % If sheet 1 is smaller than main header, expand table
                h.Row_IDs_for_sheet1 = cell(1,11);
                sheet1.table = ...
                    [sheet1.table , cell(size(sheet1.table,1),11-size(sheet1.table,2))];
            else
                h.Row_IDs_for_sheet1 = cell(1,sheet1.max_column_size);
            end
            h.Row_IDs_for_sheet1{1,1} = 'Active power loss analysis - summary';
            h.Row_IDs_for_sheet1{1,2} = 'Scenario';
            h.Row_IDs_for_sheet1{1,3} = ext_obj.Scenarios{obj.S};
            h.Row_IDs_for_sheet1{1,4} = 'Grid';
            h.Row_IDs_for_sheet1{1,5} = ext_obj.Grid_Variants{obj.G};
 
            % Add main header to table
            sheet1.table = [h.Row_IDs_for_sheet1;sheet1.table];
            sheet1.table(2:end,1:sheet1.max_column_size) = inpval;
            % OUTPUT FROM FUNCTION
            obj.Sheet.Sheet1 =  sheet1.table;
            
        end 
        % compare datasets
        
        function compare_grids(obj,ext_obj,input)  
            
            % XLS_RESULTS > GRIDSUMMARY_FULL
                        
            h.Column_IDs_for_Grids = [];
            for cg = 1 : numel(ext_obj.Grid_Variants)
                h.Column_IDs_for_Grids{1,cg} = ext_obj.Grid_Variants{cg};
            end            
            h.Column_IDs_for_Grids = [{''},h.Column_IDs_for_Grids];
            xls_results.GridSummary = num2cell(input.GridSummary);
            clear xls_block xls_inp1 xls_inp2 cg cd
            
            h.Row_IDs_for_GridSummary{1,1} = 'Sum of active power losses for scenario (Wh)';
            h.Row_IDs_for_GridSummary{2,1} = 'Mean value of active power losses for scenario (Wh)';
            h.Row_IDs_for_GridSummary{3,1} = 'St. dev. of active power losses for scenario (Wh)';
            h.Row_IDs_for_GridSummary{4,1} = 'Max. active power loss for scenario (Wh/h)';
                        
            sheet1.table = [];
            sheet1.table = xls_results.GridSummary;
            sheet1.table = [h.Row_IDs_for_GridSummary,sheet1.table];
            sheet1.table = [h.Column_IDs_for_Grids;sheet1.table];
            
            h.Column_IDs_for_GridSummary = cell(1,size(sheet1.table,2));
            h.Column_IDs_for_GridSummary{1,1} = 'Active power loss summary comparison for grids';
            h.Column_IDs_for_GridSummary{1,2} = 'Scenario';
            h.Column_IDs_for_GridSummary{1,3} = ext_obj.Scenarios{obj.S};    
            sheet1.table = [h.Column_IDs_for_GridSummary;sheet1.table];
            
            % OUTPUT FROM FUNCTION            
            obj.Sheet.Sheet1 =  sheet1.table;
        end
        % function compare_grids
        
        
        function  compare_grids_all_scenarios(obj,ext_obj,input)
            
            for S = 1 : numel(ext_obj.Scenarios)
                input1 = [];
                input1 = input.(['S_', int2str(S)]).sheet1;
                % Correct the header for all scenario report
                h.Column_IDs_for_sheet1_correction = input1(1:2,:);
                input1{1,1} = 'Active power loss comparison for grids and scenarios - summary';
                
                % XLS_RESULTS.SHEET.GRIDSUMMARY_SCENARIO : Includes
                % input.(['S_', ext_obj.Scenarios{S}]).gridsummary
                if S == 1
                    h.empty_row_between_grid_results = 1;
                    sheet1.curr_row = 0;
                    sheet1.table = [];
                    sheet1.table = [sheet1.table; input1];
                else
                    if size(sheet1.table,2) < size(input1,2)
                        sheet1.table = [sheet1.table, cell(size(sheet1.table,1),size(input1,2) - size(sheet1.table,2))];
                    elseif size(sheet1.table,2) > size(input1,2)
                        sheet1.table(sheet1.curr_row + (1:size(input1,1)),1:size(input1,2)) = input1;
                    else
                        sheet1.table = [sheet1.table; input1];
                    end
                end
                % Add empty line
                if S ~= numel(ext_obj.Scenarios)
                    sheet1.table = [sheet1.table; cell(h.empty_row_between_grid_results,size(sheet1.table,2))];
                    sheet1.curr_row = size(sheet1.table,1);
                end
                
                % OUTPUT FROM FUNCTION
                obj.Sheet.Sheet1 =  sheet1.table;
                
            end
            end
        % function compare_grids_all_scenarios
        
  
        function display_branch_values(obj,ext_obj,input)            
                            
                h.timeplot_for_branch_Row_IDs = [];
                h.timeplot_for_branch_Row_IDs(:,1) = 1 : ext_obj.Timepoints;
                
                % Add column headers 1st row
                h.timeplot_for_branch_Column_IDs = [];
                h.timeplot_for_branch_Column_IDs{1,1} = 'Timepoint';
                h.timeplot_for_branch_Column_IDs{1,2} = 'Phase L1';
                h.timeplot_for_branch_Column_IDs{1,3} = 'Phase L2';
                h.timeplot_for_branch_Column_IDs{1,4} = 'Phase L3';
                h.timeplot_for_branch_Column_IDs{1,5} = 'Thermal limit';
                h.timeplot_for_branch_Column_IDs{1,6} = 'Branch violations';
                
                h.timeplot_for_branch_Column_IDs = [cell(1,6);h.timeplot_for_branch_Column_IDs];
                h.timeplot_for_branch_Column_IDs{1,1} = ['Grid ', ext_obj.Grid_Variants{obj.G}];
                h.timeplot_for_branch_Column_IDs{1,2} = ['Scenario ', ext_obj.Grid_Variants{obj.S}];
                h.timeplot_for_branch_Column_IDs{1,3} = ['Set ', int2str(obj.D)];
                h.timeplot_for_branch_Column_IDs{1,4} = ['Branch name: ', obj.B ];
                h.timeplot_for_branch_Column_IDs{1,6} = 'Values in A';
                
                % Create xls_results.timeplot_for_branch
                xls_results.timeplot_for_branch = ...
                    num2cell([h.timeplot_for_branch_Row_IDs,...
                    input]);
                
                xls_results.timeplot_for_branch = ...
                    [h.timeplot_for_branch_Column_IDs;...
                    xls_results.timeplot_for_branch];
                
                % OUTPUT FROM FUNCTION                
                obj.Sheet.Sheet1 = xls_results.timeplot_for_branch;            
        end
        % function display_branch_values
        
        
        function scenario(obj,S)
            obj.S = S;
        end
        % set scenario
        function grid(obj,G)
            obj.G = G;
        end
        % set grid
        function dataset(obj,D)
            obj.D = D;
        end
        % set dataset 
        function branch(obj,B)
            obj.B = B;
        end
        % set branch
        
        function voltage_levels(obj,Voltage_Levels)
            for i = 1 : numel(Voltage_Levels)
                if size(int2str(Voltage_Levels(i)),2)<=3
                    obj.Voltage_Levels{i} = [int2str(Voltage_Levels(i)), ' V'];
                else
                    obj.Voltage_Levels{i} = [int2str(Voltage_Levels(i)/1000), ' kV'];
                end
            end
            obj.Voltage_Levels{i+1} = 'Network';            
        end
        
    end
end