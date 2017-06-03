classdef Excel_Output_Voltages < handle    
    % EXCEL_OUTPUT    Voltage violation post processing  class
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
        N; % Node
    end
    
    
    methods
        function obj = Excel_Output_Voltages()
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
            h.Column_IDs_for_Summary{1,1} = 'Number of voltage violations for dataset';
            h.Column_IDs_for_Summary{1,2} = 'Amount of time voltage violations occured in %';
            h.Column_IDs_for_Summary{1,3} = 'Number of nodes where voltage violations occured';
            h.Column_IDs_for_Summary{1,4} = 'Amount of nodes in grid where voltage violations occured in %';

            xls_results.Summary = [h.Column_IDs_for_Summary;num2cell(input.Summary)];
            xls_results.Summary = [h.Row_IDs_for_Datasets, xls_results.Summary];

            % XLS_RESULTS > VIOLATED_NODES : A list of nodes where
            % violations occured for each dataset   
            h.Column_IDs_for_Violated_nodes{1,1} = 'Nodes with voltage violation occurances';
            if size(input.Violated_nodes,2) > 1
                h.Column_IDs_for_Violated_nodes = [h.Column_IDs_for_Violated_nodes, cell(1,size(input.Violated_nodes,2)-1)];
            end      
            if ~isempty(input.Violated_nodes)
                xls_results.Violated_nodes = [h.Column_IDs_for_Violated_nodes;
                    input.Violated_nodes];
            else
                xls_results.Violated_nodes = [{''};repmat({'No violations'},ext_obj.Datasets,1)];
            end
            xls_results.Violated_nodes = ...
                [h.Row_IDs_for_Datasets,xls_results.Violated_nodes];
            if ext_obj.Simulation_Options.Save_Voltage_Results == 1            
                % Header for Column IDs for Voltage statistics
                h.Column_IDs_for_Voltage_statistics_w_Nodes{1,1} = 'Max. voltage (p.u.)';
                h.Column_IDs_for_Voltage_statistics_w_Nodes{1,2} = 'Max. voltage at node';
                h.Column_IDs_for_Voltage_statistics_w_Nodes{1,3} = 'Min. voltage (p.u.)';
                h.Column_IDs_for_Voltage_statistics_w_Nodes{1,4} = 'Min. voltage at node';
                h.Column_IDs_for_Voltage_statistics_w_Nodes{1,5} = 'Max. phase-phase voltage difference (p.u.)';
                h.Column_IDs_for_Voltage_statistics_w_Nodes{1,6} = 'Max. phase-phase voltage difference at node';
                h.Column_IDs_for_Voltage_statistics_w_Nodes{1,7} = 'Mean voltage (p.u.)';
                h.Column_IDs_for_Voltage_statistics_w_Nodes{1,8} = 'St. dev. voltage (p.u.)';

                xls_results.Voltage_statistics = [...
                    num2cell(input.Voltage_statistics(:,1)),input.Voltage_statistics_at_Node(:,1),...
                    num2cell(input.Voltage_statistics(:,2)),input.Voltage_statistics_at_Node(:,2),...
                    num2cell(input.Voltage_statistics(:,3)),input.Voltage_statistics_at_Node(:,3),...
                    num2cell(input.Voltage_statistics(:,4)),...
                    num2cell(input.Voltage_statistics(:,5)),...
                    ];                
                xls_results.Voltage_statistics = ...
                    [h.Column_IDs_for_Voltage_statistics_w_Nodes;
                    xls_results.Voltage_statistics];
            else
                xls_results.Voltage_statistics = [];                
            end
            
            % XLS_RESULTS > LOAD_INFEED_VALUES : Values of load,
            % infeed and e-mobility for specific dataset
            xls_results.Load_infeed_values_at_Violation = [];
            take_into_account_Q_infeed = zeros(ext_obj.Datasets,1);
            take_into_account_Q_elmob = zeros(ext_obj.Datasets,1);            
            empty_row_for_LI_values = 1;
            if max(input.Summary(:,1)) ~= 0 % If violations exist
                h.empty_row_for_LI_values = cell(empty_row_for_LI_values, max(input.Summary(:,1))+1);
            else % If no violations exist
                h.empty_row_for_LI_values = cell(empty_row_for_LI_values, 2);
            end
            
            for cd = 1 : ext_obj.Datasets                
                if sum(input.Load_infeed_values_at_Violation{cd,1}(5,:) == 0) == size(input.Load_infeed_values_at_Violation{cd,1},2)
                    take_into_account_Q_infeed(cd,1) = 1;
                    % If reactive power is not present at infeed = 1
                end
                if sum(input.Load_infeed_values_at_Violation{cd,1}(7,:) == 0) == size(input.Load_infeed_values_at_Violation{cd,1},2)
                    take_into_account_Q_elmob(cd,1) = 1;
                    % If reactive power is not present at el mobility = 1
                end                
                if ~isempty(input.Load_infeed_values_at_Violation{cd,1})
                    h.Row_IDs_for_LI_values{cd}{1,1} = ['Set ', int2str(cd) ];
                    h.Row_IDs_for_LI_values{cd}{2,1} = 'Timepoint';
                    h.Row_IDs_for_LI_values{cd}{3,1} = 'Households (W)';
                    h.Row_IDs_for_LI_values{cd}{4,1} = 'Households (VA)';
                    h.Row_IDs_for_LI_values{cd}{5,1} = 'Solar infeed (W)';
                    h.Row_IDs_for_LI_values{cd}{6,1} = 'Solar infeed (VA)';
                    h.Row_IDs_for_LI_values{cd}{7,1} = 'El. mobility (W)';
                    h.Row_IDs_for_LI_values{cd}{8,1} = 'El. mobility (VA)';
                    h.Row_IDs_for_LI_values{cd}{9,1} = 'System balance (W)';
                    h.Row_IDs_for_LI_values{cd}{10,1} ='System balance (VA)';
                    h.Column_IDs_for_LI_values{cd}{1,1} = 'Voltage violations at timepoints';
                    h.Column_IDs_for_LI_values{cd} = [h.Column_IDs_for_LI_values{cd}{1,1},cell(1,max(input.Summary(:,1))-1)];
                else
                    h.Column_IDs_for_LI_values{cd}{1,1} = ['Set ', int2str(cd) ];
                    h.Column_IDs_for_LI_values{cd}{1,2} = 'No voltage violations at any timepoint';
                    h.Column_IDs_for_LI_values{cd} = [h.Column_IDs_for_LI_values{cd}, cell(1,max(input.Summary(:,1))-2+1)];
                end                
                if ~isempty(input.Load_infeed_values_at_Violation{cd,1})
                    xls_block = cell(size(h.Row_IDs_for_LI_values{cd},1)-1, max(input.Summary(:,1)));
                    xls_block(:,1:size(input.Load_infeed_values_at_Violation{cd,1},2)) = ...
                        num2cell(input.Load_infeed_values_at_Violation{cd,1});
                    xls_block = [h.Column_IDs_for_LI_values{cd};xls_block];
                    xls_block = [h.Row_IDs_for_LI_values{cd},xls_block];
                    xls_block = [xls_block; h.empty_row_for_LI_values];                    
                    % If solar/emobility do not have reactive power, the
                    % rows are deleted
                    del_rows = [];
                    if take_into_account_Q_infeed(cd,1) == 1
                        del_rows = [del_rows; 6];
                    end
                    if take_into_account_Q_elmob(cd,1) == 1
                        del_rows = [del_rows; 8];
                    end
                    xls_block(del_rows,:) = [];
                else
                    xls_block = h.Column_IDs_for_LI_values{cd};
                    xls_block = [xls_block; h.empty_row_for_LI_values];
                end
                
                xls_results.Load_infeed_values_at_Violation = ...
                    [xls_results.Load_infeed_values_at_Violation;xls_block];
            end
            clear cd pliv xls_block
            % Last line does not require an empty row
            xls_results.Load_infeed_values_at_Violation(end,:) = [];
            
            % XLS_RESULTS.SHEET.SUMMARY (DATASET COMPARISON) Includes 
            % xls_results.Summary,xls_results.Voltage_statistics and
            % xls_results.Violated_nodes            
            sheet1.max_column_size = size([xls_results.Summary, xls_results.Voltage_statistics],2);
            sheet1.max_column_size = max([sheet1.max_column_size,size(xls_results.Violated_nodes,2)]);
            sheet1.empty_rows = 1; % Empty rows between Summary and Violated nodes
            sheet1.max_row_size = size(input.Summary,1) + sheet1.empty_rows + size(xls_results.Violated_nodes,1);
            sheet1.table = cell(sheet1.max_row_size,sheet1.max_column_size);            
            
            % Merge tables together
            inpval = [];
            inpval = [xls_results.Summary];
            % If save voltage results exist, add Voltage_statistics to sheet1
            if ext_obj.Simulation_Options.Save_Voltage_Results == 1
                inpval = [inpval, xls_results.Voltage_statistics];
            end
            sheet1.curr_row = size(inpval,1); % current row
            sheet1.curr_col = size(inpval,2); % Current column            
            sheet1.table(1: sheet1.curr_row,1:sheet1.curr_col) = inpval;            
            % Move current row by "empty spaces"
            sheet1.curr_row = sheet1.curr_row + sheet1.empty_rows;
            
            % Second part is the list of nodes
            inpval = [];
            inpval = xls_results.Violated_nodes;
            sheet1.table(sheet1.curr_row + (1:size(inpval,1)) , 1 : size(inpval,2)) = inpval;
            
            if sheet1.max_column_size < 11
                % If sheet 1 is smaller than main header, expand table
                h.Row_IDs_for_sheet1 = cell(1,11);
                sheet1.table = ...
                    [sheet1.table , cell(size(sheet1.table,1),11-size(sheet1.table,2))];
            else
                h.Row_IDs_for_sheet1 = cell(1,sheet1.max_column_size);
            end
            h.Row_IDs_for_sheet1{1,1} = 'Voltage violation analysis - summary';
            h.Row_IDs_for_sheet1{1,4} = 'Scenario';
            h.Row_IDs_for_sheet1{1,5} = ext_obj.Scenarios{obj.S};
            h.Row_IDs_for_sheet1{1,7} = 'Grid';
            h.Row_IDs_for_sheet1{1,8} = ext_obj.Grid_Variants{obj.G};
 
            % Add main header to table
            sheet1.table = [h.Row_IDs_for_sheet1;sheet1.table];

            % XLS_RESULTS.SHEET.LOAD_INFEED (DATASET COMPARISON) Includes
            % xls_results.Summary,xls_results.Voltage_statistics and
            % xls_results.Violated_nodes            
            sheet2.table = xls_results.Load_infeed_values_at_Violation;
            sheet2.max_column_size = size(xls_results.Load_infeed_values_at_Violation,2);            
            if sheet2.max_column_size < 11
                % If sheet 2 is smaller than main header, expand table
                h.Row_IDs_for_sheet2 = cell(1,11);
                sheet2.table = ...
                    [sheet2.table , cell(size(sheet2.table,1),11-size(sheet2.table,2))];
            else
                h.Row_IDs_for_sheet2 = cell(1,sheet2.max_column_size);
            end            
            h.Row_IDs_for_sheet2{1,1} = ...
                'Voltage violation analysis - load/infeed values at voltage violations';
            h.Row_IDs_for_sheet2{1,4} = 'Scenario';
            h.Row_IDs_for_sheet2{1,5} = ext_obj.Scenarios{obj.S};
            h.Row_IDs_for_sheet2{1,7} = 'Grid';
            h.Row_IDs_for_sheet2{1,8} = ext_obj.Grid_Variants{obj.G};                       
            % Add main header to table
            sheet2.table = [h.Row_IDs_for_sheet2;sheet2.table];
            
            % OUTPUT FROM FUNCTION
            obj.Sheet.Sheet1 =  sheet1.table;
            obj.Sheet.Sheet2 =  sheet2.table;
            
        end 
        % compare datasets
        
        function compare_grids(obj,ext_obj,input)
            
            % XLS_RESULTS > GRIDSUMMARY_FULL 
            if ext_obj.x_axis_value == 2
                h.Column_IDs_for_GridSummary_full_1{1,1} = 'Voltage violations in % of time for different grids ';
                h.Column_IDs_for_GridSummary_full_2{1,1} = 'Number of nodes with voltage violations in % of time for different grids ';
            elseif ext_obj.x_axis_value == 1
                h.Column_IDs_for_GridSummary_full_1{1,1} = 'Number of voltage violations for different grids ';
                h.Column_IDs_for_GridSummary_full_2{1,1} = 'Number of nodes with voltage violations for different grids ';
            end            
            if numel(ext_obj.Grid_Variants) > 1
                h.Column_IDs_for_GridSummary_full_1(1,2:numel(ext_obj.Grid_Variants)) = ...
                    cell(1,numel(ext_obj.Grid_Variants)-1);
                h.Column_IDs_for_GridSummary_full_2(1,2:numel(ext_obj.Grid_Variants)) = ...
                    cell(1,numel(ext_obj.Grid_Variants)-1);
            end
            h.Column_IDs_for_GridSummary_full_1(2,1: numel(ext_obj.Grid_Variants)) = ext_obj.Grid_Variants;
            h.Column_IDs_for_GridSummary_full_2(2,1: numel(ext_obj.Grid_Variants)) = ext_obj.Grid_Variants;
            
            h.Row_IDs_for_Datasets = [];
            for cd = 1 : ext_obj.Datasets
                h.Row_IDs_for_Datasets{cd,1} = ['Set ' int2str(cd)];
            end            
            h.Row_IDs_for_Datasets = [{'Dataset'};h.Row_IDs_for_Datasets];
            h.Row_IDs_for_Datasets_for_GridSummary_full = [{''};h.Row_IDs_for_Datasets];
            xls_block = [];
            xls_block = [xls_block,num2cell(squeeze(input.GridSummary_Full(:,:,ext_obj.x_axis_value)))];
            xls_block = [xls_block,num2cell(squeeze(input.GridSummary_Full(:,:,ext_obj.x_axis_value+2)))];            
            xls_block = [h.Column_IDs_for_GridSummary_full_1, h.Column_IDs_for_GridSummary_full_2;xls_block];
            xls_block = [h.Row_IDs_for_Datasets_for_GridSummary_full,xls_block];            
            xls_results.GridSummary_Full = xls_block;
            clear xls_block
            
            % XLS_RESULTS > GRIDSUMMARY_SHORT
            %   The values can be displayed numerically or in %
            %   if obj.x_axis_value is set to 2, values are shown in %, if
            %   value is set to 1, values are shown numerically
            if ext_obj.x_axis_value == 2
                h.Column_IDs_for_GridSummary_short_1{1,1} = 'Statistical analysis of voltage violations in % of time for different grids ';
                h.Column_IDs_for_GridSummary_short_1{1,2} = '';
                h.Column_IDs_for_GridSummary_short_1{1,3} = '';
                h.Column_IDs_for_GridSummary_short_1{2,1} = 'Max % of voltage violations at grid';
                h.Column_IDs_for_GridSummary_short_1{2,2} = 'Min % of voltage violations at grid';
                h.Column_IDs_for_GridSummary_short_1{2,3} = 'Mean value of the % of voltage violations at grid';
                
                h.Column_IDs_for_GridSummary_short_2{1,1} = 'Statistical analysis of the % of nodes with voltage violations for different grids ';;
                h.Column_IDs_for_GridSummary_short_2{1,2} = '';
                h.Column_IDs_for_GridSummary_short_2{1,3} = '';
                h.Column_IDs_for_GridSummary_short_2{2,1} = 'Max % of nodes with voltage violations at grid';
                h.Column_IDs_for_GridSummary_short_2{2,2} = 'Min % of nodes with voltage violations at grid';
                h.Column_IDs_for_GridSummary_short_2{2,3} = 'Mean value of the % of nodes with voltage violations at grid';
                
            elseif ext_obj.x_axis_value == 1
                h.Column_IDs_for_GridSummary_short_1{1,1} = 'Statistical analysis of the number of voltage violations for different grids ';
                h.Column_IDs_for_GridSummary_short_1{1,2} = '';
                h.Column_IDs_for_GridSummary_short_1{1,3} = '';
                h.Column_IDs_for_GridSummary_short_1{1,4} = '';
                h.Column_IDs_for_GridSummary_short_1{2,1} = 'Max number of voltage violations at grid';
                h.Column_IDs_for_GridSummary_short_1{2,2} = 'Min number of voltage violations at grid';
                h.Column_IDs_for_GridSummary_short_1{2,3} = 'Mean value of the number of voltage violations at grid';
                h.Column_IDs_for_GridSummary_short_1{2,4} = 'Sum of all number of voltage violations at grid';
                
                h.Column_IDs_for_GridSummary_short_2{1,1} = 'Statistical analysis of the number of nodes with voltage violations for different grids ';;
                h.Column_IDs_for_GridSummary_short_2{1,2} = '';
                h.Column_IDs_for_GridSummary_short_2{1,3} = '';
                h.Column_IDs_for_GridSummary_short_2{2,1} = 'Max number of nodes with voltage violations at grid';
                h.Column_IDs_for_GridSummary_short_2{2,2} = 'Min number of nodes with voltage violations at grid';
                h.Column_IDs_for_GridSummary_short_2{2,3} = 'Mean value of the number of nodes with voltage violations at grid';
            end
            
            h.Row_IDs_for_Grids = [];
            for cg = 1 : numel(ext_obj.Grid_Variants)
                h.Row_IDs_for_Grids{cg,1} = ['Grid: ' ext_obj.Grid_Variants{cg}];
            end
            h.Row_IDs_for_Grids = [{'Grids'};h.Row_IDs_for_Grids];
            h.Row_IDs_for_Grids_for_Summary_short = ...
                [{''};h.Row_IDs_for_Grids];
            
            % Delete NaN values from excel results
            xls_inp1 = []; xls_inp2 = [];
            xls_inp1 = squeeze(input.GridSummary_Short(:,ext_obj.x_axis_value,:));
            xls_inp1(:, sum(isnan(xls_inp1),1) == size(xls_inp1,1)) = [];
            xls_inp2 = squeeze(input.GridSummary_Short(:,ext_obj.x_axis_value+2,:));
            xls_inp2(:, sum(isnan(xls_inp2),1) == size(xls_inp2,1)) = [];
            
            xls_block = [];
            xls_block = [xls_block,num2cell(xls_inp1)];
            xls_block = [xls_block,num2cell(xls_inp2)];
            
            if ~isempty(xls_block)
                xls_block = [h.Column_IDs_for_GridSummary_short_1,h.Column_IDs_for_GridSummary_short_2;
                    xls_block];
            else
                xls_block = repmat({'No voltage violations at any grid'},numel(ext_obj.Grid_Variants),1);
                xls_block=[{''};{''};xls_block];
            end
            
            xls_block = [h.Row_IDs_for_Grids_for_Summary_short,xls_block];
            
            xls_results.GridSummary_Short = xls_block;
            clear xls_block xls_inp1 xls_inp2 cg cd
            
            % XLS_RESULTS > GRIDVOLTAGE_STATISTICS
            if ext_obj.Simulation_Options.Save_Voltage_Results == 1
                %   The values can be displayed numerically or in %
                %   if obj.x_axis_value is set to 2, values are shown in %, if
                %   value is set to 1, values are shown numerically
                
                h.Column_IDs_for_GridVoltage_statistics{1,1} = 'Statistical analysis of voltage results for different grids';
                h.Column_IDs_for_GridVoltage_statistics(1,2:11) = cell(1,10);                
                h.Column_IDs_for_GridVoltage_statistics{2,1} = 'Max voltage value at grid';
                h.Column_IDs_for_GridVoltage_statistics{2,2} = 'Node with max voltage value at grid';
                h.Column_IDs_for_GridVoltage_statistics{2,3} = 'Min voltage value at grid';
                h.Column_IDs_for_GridVoltage_statistics{2,4} = 'Node with min voltage value at grid';
                h.Column_IDs_for_GridVoltage_statistics{2,5} = 'Max Upp difference at grid';
                h.Column_IDs_for_GridVoltage_statistics{2,6} = 'Node with max Upp difference at grid';
                h.Column_IDs_for_GridVoltage_statistics{2,7} = 'Mean value of voltages at grid';
                h.Column_IDs_for_GridVoltage_statistics{2,8} = 'Average st. dev. of voltages at grid';                
                h.Column_IDs_for_GridVoltage_statistics{2,9} = 'Max voltages occur most often at node(s)';
                h.Column_IDs_for_GridVoltage_statistics{2,10} = 'Min voltages occur most often at node(s)';
                h.Column_IDs_for_GridVoltage_statistics{2,11} = 'Max Upp differences occur most often at node(s)';
                                
                h.Row_IDs_for_Grids_for_GridVoltage_statistics = [{''};h.Row_IDs_for_Grids];
                
                % Merge multiple elements into one, but seperate with commas
                xls_inp1 = []; xls_inp = [];
                xls_inp1 = input.GridVoltage_statistics_at_Node;
                for i = 1 : size(xls_inp1,1)
                    for j = 1 : size(xls_inp1,2)
                        if iscell(xls_inp1{i,j})
                            if size(xls_inp1{i,j},1) > 1
                                % If more than one element is listed
                                xls_rep = [];
                                for k = 1 :  size(xls_inp1{i,j},1)
                                    if k == size(xls_inp1{i,j},1)
                                        xls_rep = [xls_rep,xls_inp1{i,j}{k}];
                                    else
                                        xls_rep = [xls_rep,xls_inp1{i,j}{k},','];
                                    end
                                end
                                xls_inp1{i,j} = xls_rep;
                            else
                                xls_inp1{i,j} =  xls_inp1{i,j}{:};
                            end                            
                        end
                    end
                end
                
                xls_inp = ...
                    [num2cell(input.GridVoltage_statistics(:,1)),xls_inp1(:,1),...
                     num2cell(input.GridVoltage_statistics(:,2)),xls_inp1(:,2),...
                     num2cell(input.GridVoltage_statistics(:,3)),xls_inp1(:,3),...
                     num2cell(input.GridVoltage_statistics(:,4)),...
                     num2cell(input.GridVoltage_statistics(:,5)),...
                     xls_inp1(:,4), xls_inp1(:,5), xls_inp1(:,6)];
                
                xls_block = [];
                xls_block = [xls_block,xls_inp];
                xls_block = [h.Column_IDs_for_GridVoltage_statistics;xls_block];                
                xls_results.GridVoltage_statistics = xls_block;
                clear xls_block xls_inp1 xls_inp xls_rep i j k
            else
                xls_results.GridVoltage_statistics = [];
            end
            
            % XLS_RESULTS.SHEET.GRIDSUMMARY (DATASET COMPARISON) Includes
            % xls_results.GridSummary_Short,xls_results.GridVoltage_statistics
            sheet1.max_column_size = size([xls_results.GridSummary_Short,xls_results.GridVoltage_statistics],2);
            sheet1.max_row_size = size(xls_results.GridSummary_Short,1);            
            if ~isempty(xls_results.GridVoltage_statistics)
                if size(xls_results.GridVoltage_statistics,1) ~= sheet1.max_row_size
                    error('Grid comparison rows do not match for voltage results and grid summary')
                end
            end            
            sheet1.table = cell(sheet1.max_row_size,sheet1.max_column_size);            
            % Add summary to sheet1
            inpval = [];
            inpval = [xls_results.GridSummary_Short];            
            % If save voltage results exist, add Voltage_statistics to sheet1
            if ext_obj.Simulation_Options.Save_Voltage_Results == 1
                inpval = [inpval, xls_results.GridVoltage_statistics];
            end            
            % Add to table
            sheet1.table(1:size(inpval,1), 1 : size(inpval,2)) = inpval;
            
            if sheet1.max_column_size < 11
                % If sheet 1 is smaller than main header, expand table
                h.Row_IDs_for_sheet1 = cell(1,11);
                sheet1.table = [sheet1.table , cell(size(sheet1.table,1),11-size(sheet1.table,2))];
            else
                h.Row_IDs_for_sheet1 = cell(1,sheet1.max_column_size);
            end
            
            h.Row_IDs_for_sheet1{1,1} = 'Voltage violation comparison for grids - summary';
            
            if ext_obj.Simulation_Options.Save_Voltage_Results == 1
                h.Row_IDs_for_sheet1{1,4} = 'Additional voltage analysis comparison for grids';
                h.Row_IDs_for_sheet1{1,7} = 'Scenario';
                h.Row_IDs_for_sheet1{1,8} = ext_obj.Scenarios{obj.S};
            else
                h.Row_IDs_for_sheet1{1,4} = 'No additional voltage analysis comparison for grids';
                h.Row_IDs_for_sheet1{1,7} = 'Scenario';
                h.Row_IDs_for_sheet1{1,8} = ext_obj.Scenarios{obj.S};
            end
            % Add main header to table
            sheet1.table = [h.Row_IDs_for_sheet1;sheet1.table];            

            % XLS_RESULTS.SHEET.GRIDSUMMARY_EXPENDED (DATASET COMPARISON) Includes
            % xls_results.GridSummary_Full            
            sheet2.table = xls_results.GridSummary_Full;
            sheet2.max_column_size = size(xls_results.GridSummary_Full,2);            
            if sheet2.max_column_size < 11
                % If sheet 2 is smaller than main header, expand table
                h.Row_IDs_for_sheet2 = cell(1,11);
                sheet2.table = [sheet2.table , cell(size(sheet2.table,1),11-size(sheet2.table,2))];
            else
                h.Row_IDs_for_sheet2 = cell(1,sheet2.max_column_size);
            end            
            h.Row_IDs_for_sheet2{1,1} = 'Voltage violation comparison between grids';
            h.Row_IDs_for_sheet2{1,4} = 'Scenario';
            h.Row_IDs_for_sheet2{1,5} = ext_obj.Scenarios{obj.S};            
            % Add main header to table
            sheet2.table = [h.Row_IDs_for_sheet2;sheet2.table];
            
            % OUTPUT FROM FUNCTION
            obj.Sheet.Sheet1 =  sheet1.table;
            obj.Sheet.Sheet2 =  sheet2.table;           
        end
        % function compare_grids
        
        function  compare_grids_all_scenarios(obj,ext_obj,input)
            
            for S = 1 : numel(ext_obj.Scenarios)
                input1 = [];
                input1 = input.(['S_', int2str(S)]).sheet1;                
                % Correct the header for all scenario report
                h.Column_IDs_for_sheet1_correction = input1(1:2,:);
                h.Column_IDs_for_sheet1_correction{1,1} = 'Voltage violation comparison for grids and scenarios - summary';
                h.Column_IDs_for_sheet1_correction{2,1} = h.Column_IDs_for_sheet1_correction{1,8};
                h.Column_IDs_for_sheet1_correction{1,7} = '';
                h.Column_IDs_for_sheet1_correction{1,8} = '';            
                input1(1:2,:) = h.Column_IDs_for_sheet1_correction; 
                
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

                % XLS_RESULTS.SHEET.GRIDSUMMARY_SCENARIO : Includes
                % input.(['S_', ext_obj.Scenarios{S}]).gridsummary             
                if S == 1
                    sheet2.table1 = cell(ext_obj.Datasets, numel(ext_obj.Grid_Variants) * numel(ext_obj.Scenarios) );
                    sheet2.table2 = cell(ext_obj.Datasets, numel(ext_obj.Grid_Variants) * numel(ext_obj.Scenarios) );
                    % FIX!!!!
                    
                    for hS = 1 : numel(ext_obj.Scenarios)
                        h.Column_Grid_Scenario_locations(hS,:) = ...
                            (1:numel(ext_obj.Grid_Variants)) + numel(ext_obj.Grid_Variants)*(hS-1);
                    end
                    % rows are scenarios, grids are columns
                    
                    h.Column_IDs_sheet2table1 = cell(3,numel(ext_obj.Grid_Variants) * numel(ext_obj.Scenarios));
                    h.Column_IDs_sheet2table2 = cell(3,numel(ext_obj.Grid_Variants) * numel(ext_obj.Scenarios));
                    
                    if ext_obj.x_axis_value == 2
                        h.Column_IDs_sheet2table1{1,1} = 'Voltage violation comparison between grids and scenarios (in % of time)';
                        h.Column_IDs_sheet2table2{1,1} = 'Comparison of number of nodes with voltage violations in % of time for different grids and scenarios';
                    else
                        h.Column_IDs_sheet2table1{1,1} = 'Voltage violation comparison between grids and scenarios (number of times)';
                        h.Column_IDs_sheet2table2{1,1} = 'Comparison of number of nodes with voltage violations for different grids and scenarios';
                    end
                    
                    for hG = 1 : numel(ext_obj.Grid_Variants)   
                        for hS = 1 : numel(ext_obj.Scenarios)
                            ids = h.Column_Grid_Scenario_locations(hS,1);
                            h.Column_IDs_sheet2table1{2,ids} = ext_obj.Scenarios{hS};                        
                            idg = h.Column_Grid_Scenario_locations(hS,hG);
                            h.Column_IDs_sheet2table1{3,idg} = ext_obj.Grid_Variants{hG};
                        end
                    end
                    h.Column_IDs_sheet2table2(2:3,:)=h.Column_IDs_sheet2table1(2:3,:);
                    clear hS hG idg ids
                    
                    h.Row_IDs_for_Datasets = [];
                    for cd = 1 : ext_obj.Datasets
                        h.Row_IDs_for_Datasets{cd,1} = ['Set ' int2str(cd)];
                    end
                    h.Row_IDs_for_Datasets = [{'Dataset'};h.Row_IDs_for_Datasets];
                    h.Row_IDs_for_Datasets_for_sheet2 = [{''};{''};h.Row_IDs_for_Datasets];
                end
                
                for G = 1 : numel(ext_obj.Grid_Variants)
                    input2 = [];
                    input2 = input.(['S_', int2str(S)]).ScenarioGridHistogram_Violations(:,G,S);
                    input3 = [];
                    input3 = input.(['S_', int2str(S)]).ScenarioGridHistogram_Violations_at_Nodes(:,G,S);
                    idx = h.Column_Grid_Scenario_locations(S,G);
                    sheet2.table1(:,idx) = num2cell( input2 );
                    sheet2.table2(:,idx) = num2cell( input3 );
                end    
            end
            h.empty_column_between_sheet2_tables = 0;            
            sheet2.table1 = [h.Column_IDs_sheet2table1 ;sheet2.table1];
            sheet2.table1 = [h.Row_IDs_for_Datasets_for_sheet2 ,sheet2.table1];
            sheet2.table2 = [h.Column_IDs_sheet2table2 ;sheet2.table2];
            sheet2.table2 = [h.Row_IDs_for_Datasets_for_sheet2 ,sheet2.table2];            
            sheet2.table = [sheet2.table1, cell(size(sheet2.table1,1),...
                h.empty_column_between_sheet2_tables), sheet2.table2];
            
            % OUTPUT FROM FUNCTION
            obj.Sheet.Sheet1 =  sheet1.table;
            obj.Sheet.Sheet2 =  sheet2.table;     
            
        end
        % function compare_grids_all_scenarios
        
        
        function display_node_voltage(obj,ext_obj,input)            
                % XLS_RESULTS.SHEET.VOLTAGE_OVER_TIME : Includes
                % voltage over time data                
                h.timeplot_for_node_Row_IDs = [];
                h.timeplot_for_node_Row_IDs(:,1) = 1 : ext_obj.Timepoints;
                
                % Add column headers 1st row
                h.timeplot_for_node_Column_IDs = [];
                h.timeplot_for_node_Column_IDs{1,1} = 'Timepoint';
                h.timeplot_for_node_Column_IDs{1,2} = 'Phase L1';
                h.timeplot_for_node_Column_IDs{1,3} = 'Phase L2';
                h.timeplot_for_node_Column_IDs{1,4} = 'Phase L3';
                h.timeplot_for_node_Column_IDs{1,5} = 'Voltage upper limit';
                h.timeplot_for_node_Column_IDs{1,6} = 'Voltage lower limit';
                h.timeplot_for_node_Column_IDs{1,7} = 'Voltage violations';
                
                h.timeplot_for_node_Column_IDs = [cell(1,7);h.timeplot_for_node_Column_IDs];
                h.timeplot_for_node_Column_IDs{1,1} = ['Grid ', ext_obj.Grid_Variants{obj.G}];
                h.timeplot_for_node_Column_IDs{1,2} = ['Scenario ', ext_obj.Grid_Variants{obj.S}];
                h.timeplot_for_node_Column_IDs{1,3} = ['Set ', int2str(obj.D)];
                h.timeplot_for_node_Column_IDs{1,4} = ['Node name: ', obj.N ];
                h.timeplot_for_node_Column_IDs{1,6} = 'Values in p.u.';
                
                % Create xls_results.timeplot_for_node
                xls_results.timeplot_for_node = ...
                    num2cell([h.timeplot_for_node_Row_IDs,...
                    input]);
                
                xls_results.timeplot_for_node = ...
                    [h.timeplot_for_node_Column_IDs;...
                    xls_results.timeplot_for_node];
                
                % OUTPUT FROM FUNCTION                
                obj.Sheet.Sheet1 = xls_results.timeplot_for_node;            
        end
        % function display_node_voltage
        
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
        function node(obj,N)
            obj.N = N;
        end
        % set node
    end
end